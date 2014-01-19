/*
 * Copyright 2013 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import org.vertx.java.core.http { HttpServerRequest_=HttpServerRequest, HttpVersion_=HttpVersion { http_1_0_=HTTP_1_0} }
import ceylon.net.uri { Uri, parseUri=parse, Query }
import ceylon.io { SocketAddress }
import io.vertx.ceylon.util { toMap }
import ceylon.promises { Promise, Deferred }
import ceylon.net.http { Method, parseMethod, post, put }
import io.vertx.ceylon { ReadStream, readStream }
import org.vertx.java.core { Handler_=Handler }
import java.lang { Void_=Void }

"Represents a server-side HTTP request. Each instance of this class is associated with a corresponding
 [[HttpServerResponse]] instance via the `response` field. Instances of this class are not thread-safe."
by("Julien Viet")
shared class HttpServerRequest(HttpServerRequest_ delegate) extends HttpInput() {
        
    "The response. Each instance of this class has an [[HttpServerResponse]] instance attached to it.
     This is used to send the response back to the client."
    shared HttpServerResponse response = HttpServerResponse(delegate.response());
    
    "The HTTP version of the request."
    shared HttpVersion version = delegate.version() == http_1_0_ then http_1_0 else http_1_1;
    
    shared actual ReadStream stream = readStream(delegate);

    "The request method"
    shared Method method = parseMethod(delegate.method());

    "The request uri"
    shared Uri uri => parseUri(delegate.uri());

    "The request path"
    shared String path => delegate.path();

    "The query part of the request uri"
    shared Query query => uri.query;
    
    "Get the absolute URI corresponding to the the HTTP request"
    shared Uri absoluteURI => parseUri(delegate.absoluteURI().string);

    variable Deferred<Map<String, {String+}>>? formDeferred = null;
    
    "The form attributes when the request is a POST with a _application/x-www-form-urlencoded_ mime type" 
    shared Promise<Map<String, {String+}>> formAttributes {
        if (exists t = formDeferred) {
            return t.promise;
        } else {
            Deferred<Map<String, {String+}>> d = Deferred<Map<String, {String+}>>();
            String? contentType = delegate.headers().get("Content-Type");
            
            if (exists contentType, contentType.lowercased.startsWith("application/x-www-form-urlencoded") &&
                    (method == post || method == put || method.string == "PATCH")) {
                object handler satisfies Handler_<Void_> {
                    shared actual void handle(Void_ nothing) {
                        value formAttributesMap = delegate.formAttributes();
                        Map<String, {String+}> form = toMap(formAttributesMap);
                        d.resolve(form);
                    }
                } 
                delegate.expectMultiPart(true);
                delegate.endHandler(handler); 
                formDeferred = d;
            } else {
                d.reject(Exception("Request does not have an application/x-www-form-urlencoded body and is not among POST,PUT,PATCH"));
            }
            return d.promise;
        }
    }

    "The remote socket address"
    shared SocketAddress remoteAddress = SocketAddress {
        address = delegate.remoteAddress().address.hostAddress;
        port = delegate.remoteAddress().port;
    };

    // Lazy params map
    variable Map<String,{String+}>? paramsMap = null;

    "Returns a map of all the parameters in the request."
    shared Map<String, {String+}> params {
        if (exists ret = paramsMap) {
            return ret;
        } else {
            value a = toMap(delegate.params());
            paramsMap = a;
            return a;
        }
    }

    // Lazy header map
    variable Map<String,{String+}>? headerMap = null;
    shared actual Map<String,{String+}> headers {
        if (exists ret = headerMap) {
            return ret;
        } else {
            value headersMM = delegate.headers();
            return headerMap = toMap(headersMM);
        }
    }

    shared actual Promise<Body> parseBody<Body>(BodyType<Body> parser) {
        return doParseBody(parser, delegate.bodyHandler, delegate, charset);
    }
}

class InternalHttpServerRequest(shared HttpServerRequest_ delegate)
    extends HttpServerRequest(delegate) {
}