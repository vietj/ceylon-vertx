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

import org.vertx.java.core.http { HttpClient_=HttpClient, HttpClientRequest_=HttpClientRequest, HttpClientResponse_=HttpClientResponse }
import ceylon.promises { Deferred, Promise }
import org.vertx.java.core { Handler_=Handler}
import io.vertx.ceylon.interop { ExceptionSupportAdapter { setErrorHandler } }
import java.lang { Iterable_=Iterable, String_=String }
import ceylon.net.http { Method }
import io.vertx.ceylon.util { toIterableStrings }
import io.vertx.ceylon { writeStream, WriteStream }

"Represents a client-side HTTP request.
 
 Instances are created by an [[HttpClient]] instance, via one of the methods corresponding to the
 specific HTTP methods, or the generic `request` method. Once a request has been obtained, headers can be set on
 it, and data can be written to its body if required. Once you are ready to send the request, the `end()` method
 should be called.
 
 Nothing is actually sent until the request has been internally assigned an HTTP connection. The [[HttpClient]]
 instance will return an instance of this class immediately, even if there are no HTTP connections available
 in the pool. Any requests sent before a connection is assigned will be queued internally and actually sent
 when an HTTP connection becomes available from the pool.
 
 The headers of the request are actually sent either when the `end()` method is called, or, when the first
 part of the body is written, whichever occurs first.
 
 This class supports both chunked and non-chunked HTTP.
 
 An example of using this class is as follows:
 
     HttpClientRequest req = client.
         request(\"POST\", \"/some-url\").
         header(\"some-header\", \"hello\").
         header(\"Content-Length\", \"5\").
         end(\"hello\");
     req.promise.then_((HttpClientResponse resp) => print(\"Got response \`resp.status\`\");
 
 Instances of HttpClientRequest are not thread-safe."
by("Julien Viet")
shared class HttpClientRequest(HttpClient_ delegate, Method method, String uri) extends HttpOutput<HttpClientRequest>() {

    Deferred<HttpClientResponse> deferred = Deferred<HttpClientResponse>();

    """The response promise is resolved when the http client response is available.
       
       todo: consider provide an handler instead of having a Promise<Response>"""
    shared Promise<HttpClientResponse> response => deferred.promise;
    
    object valueHandler satisfies Handler_<HttpClientResponse_> {
        shared actual void handle(HttpClientResponse_ response) {
            deferred.resolve(HttpClientResponse(response));
        } 
    }

    HttpClientRequest_ request = delegate.request(method.string, uri, valueHandler);
    setErrorHandler(request, deferred);
    
    shared actual WriteStream stream = writeStream(request);
    
    "Set's the amount of time after which if a response is not received `TimeoutException`
     will be sent to the exception handler of this request. Calling this method more than once
     has the effect of canceling any existing timeout and starting the timeout from scratch."
    shared HttpClientRequest timeout(
            "The quantity of time in milliseconds"
            Integer t) {
        request.setTimeout(t);
        return this;
    }

    shared actual HttpClientRequest write(String|[String,String] chunk) {
        switch (chunk) 
        case (is String) {
            request.write(chunk);
        }
        case (is [String,String]) {
            request.write(chunk[0], chunk[1]);
        }
        return this;
    }

    shared actual HttpClientRequest end(<String|[String,String]>? chunk) {
        switch (chunk) 
        case (is String) {
            request.end(chunk);
        }
        case (is [String,String]) {
            request.end(chunk[0], chunk[1]);
        }
        case (is Null) {
            request.end();
        }
        return this;
    }

    shared actual HttpClientRequest headers({<String-><String|{String+}>>*} headers) {
        for (header_ in headers) {
            value item = header_.item;
            switch (item)
            case (is String) {
                request.putHeader(header_.key, item);
            }
            case (is {String+}) { 
                Iterable_<String_> i = toIterableStrings(item);
                request.putHeader(header_.key, i);
            }
        }
        return this;
    }
}