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

import org.vertx.java.core.http { HttpServerRequest_=HttpServerRequest }
import ceylon.net.uri { Uri, parseUri=parse, Query, Parameter }
import ceylon.io { SocketAddress }
import ceylon.collection { HashMap }
import io.vertx.ceylon.util { combine, toMap }
import ceylon.promises { Promise }

"Represents a server-side HTTP request. Each instance of this class is associated with a corresponding
 [[HttpServerResponse]] instance via the `response` field. Instances of this class are not thread-safe."
by("Julien Viet")
shared class HttpServerRequest(
    HttpServerRequest_ delegate,
    Map<String, {String+}>? formParameters_ = null)
            extends HttpInput() {
        
    "The response. Each instance of this class has an [[HttpServerResponse]] instance attached to it.
     This is used to send the response back to the client."
    shared HttpServerResponse response = HttpServerResponse(delegate.response());

    "The request method"
    shared String method => delegate.method();

    "The request uri"
    shared Uri uri => parseUri(delegate.uri());

    "The request path"
    shared String path => delegate.path();

    "The query part of the request uri"
    shared Query query => uri.query;

    "The form parameters when the request is a POST with a _application/x-www-form-urlencoded_ mime type" 
    shared Map<String, {String+}>? formParameters = formParameters_;

    "The remote socket address"
    shared SocketAddress remoteAddress = SocketAddress {
        address = delegate.remoteAddress().address.hostAddress;
        port = delegate.remoteAddress().port;
    };

    // Lazy query parameter map
    variable Map<String, {String+}>? queryMap = null;

    "Return the query parameters of this request"
    shared Map<String, {String+}> queryParameters {
        if (exists ret = queryMap) {
            return ret;
        } else {
            HashMap<String, {String+}> map = HashMap<String, {String+}>();
            for (Parameter parameter in query.parameters.reversed) {
                if (exists val = parameter.val) {
                    variable {String+}? previous = map[parameter.name];
                    {String+} values;
                    if (exists rest = previous) {
                        values = { val, *rest };
                    } else {
                        values = { val };
                    }
                    map.put(parameter.name, values);
                } 
            }
            return queryMap = map;
        }
    }

    // Lazy parameter map
    variable Map<String,{String+}>? parameterMap = null;

    "Returns all the parameters of this request. When the request is a POST request with an mime type
      _application/x-www-form-urlencoded_ the form is decoded and the query and form parameters are aggregated
      in the returned parameter map."
    shared Map<String, {String+}> parameters {
        if (exists ret = parameterMap) {
            return ret;
        } else {
            if (exists formParameters) {
                return parameterMap = combine(formParameters, combine(queryParameters));
            } else {
                return parameterMap = queryParameters;
            }
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
        if (exists formParameters_) {
            throw Exception("Form body cannot be parsed -> use formParameters instead");
        }
        return doParseBody(parser, delegate.bodyHandler, delegate, charset);
    }

}