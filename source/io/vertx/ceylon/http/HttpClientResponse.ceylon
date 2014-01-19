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
import io.vertx.ceylon.util { toMap }
import ceylon.promises { Promise }
import org.vertx.java.core.http { HttpClientResponse_=HttpClientResponse }
import io.vertx.ceylon { ReadStream, readStream }

"Represents a client-side HTTP response. Instances of this class are not thread-safe."
by("Julien Viet")
shared class HttpClientResponse(HttpClientResponse_ delegate)
        extends HttpInput() {

    "The HTTP status code of the response"
    shared Integer statusCode => delegate.statusCode();

    "The HTTP status code of the response"
    shared String statusMessage => delegate.statusMessage();

    "The http headers"
    shared actual Map<String,{String+}> headers = toMap(delegate.headers());

    shared actual ReadStream stream = readStream(delegate);

    shared actual Promise<Body> parseBody<Body>(BodyType<Body> parser) {
        return doParseBody(parser, delegate.bodyHandler, delegate, charset);
    }
}