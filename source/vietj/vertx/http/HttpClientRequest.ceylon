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
import vietj.promises { Deferred, Promise }
import org.vertx.java.core { Handler_=Handler}
import vietj.vertx.interop { ExceptionSupportAdapter { handle } }
import java.lang { Exception }

by "Julien Viet"
license "ASL2"
doc "Represents a client-side HTTP request.
     
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
shared class HttpClientRequest(HttpClient_ delegate, String method, String uri) extends HttpOutput<HttpClientRequest>() {
	
	Deferred<HttpClientResponse> deferred = Deferred<HttpClientResponse>();
	
	doc "The response promise is resolved when the http client response is available."
	shared Promise<HttpClientResponse> response => deferred.promise;

	object valueHandler satisfies Handler_<HttpClientResponse_> {
		shared actual void handle(HttpClientResponse_ response) {
			deferred.resolve(HttpClientResponse(response));
		} 
	}

	HttpClientRequest_ request = delegate.request(method, uri, valueHandler);
	handle(request, deferred);
	
	doc "Set's the amount of time after which if a response is not received `TimeoutException`
         will be sent to the exception handler of this request. Calling this method more than once
         has the effect of canceling any existing timeout and starting the timeout from scratch."
	shared HttpClientRequest timeout(doc "The quantity of time in milliseconds" Integer t) {
		request.setTimeout(t);
		return this;
	}
	
	shared actual HttpClientRequest end(String? chunk) {
		if (exists chunk) {
			request.end(chunk);
		} else {
			request.end();
		}
		return this;
	}
	
	shared actual HttpClientRequest headers(<String-><String|{String+}>>* headers) {
		for (header_ in headers) {
			value item = header_.item;
			switch (item)
				case (is String) {
					request.putHeader(header_.key, item);
				}
				case (is {String+}) { 
					throw Exception("Cannot be implemented now : ambiguous reference to overloaded method or class: putHeader");
				}
		}
		return this;
	}
}