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
import ceylon.promises { Promise }
import ceylon.net.http { Method, parseMethod }
import io.vertx.ceylon { ReadStream, readStream }

"Represents a server-side HTTP request. Each instance of this class is associated with a corresponding
 [[HttpServerResponse]] instance via the `response` field. Instances of this class are not thread-safe."
by("Julien Viet")
shared class HttpServerRequest(
    HttpServerRequest_ delegate,
    Map<String, {String+}>? formAttributesMap_ = null)
            extends HttpInput() {
        
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

    "The form attributes when the request is a POST with a _application/x-www-form-urlencoded_ mime type" 
    // Consider using a Promise for this instead
    shared Map<String, {String+}>? formAttributes = formAttributesMap_;

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
        if (exists formAttributesMap_) {
            throw Exception("Form body cannot be parsed -> use formParameters instead");
        }
        return doParseBody(parser, delegate.bodyHandler, delegate, charset);
    }
}

class InternalHttpServerRequest(shared HttpServerRequest_ delegate, Map<String, {String+}>? formAttributesMap_ = null)
    extends HttpServerRequest(delegate, formAttributesMap_) {
}