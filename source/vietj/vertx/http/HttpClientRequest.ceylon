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
shared class HttpClientRequest(HttpClient_ delegate, String method, String uri) extends HttpOutput<HttpClientRequest>() {
	
	Deferred<HttpClientResponse> deferred = Deferred<HttpClientResponse>();
	shared Promise<HttpClientResponse> promise => deferred.promise;

	object valueHandler satisfies Handler_<HttpClientResponse_> {
		shared actual void handle(HttpClientResponse_ response) {
			deferred.resolve(HttpClientResponse(response));
		} 
	}

	HttpClientRequest_ request = delegate.request(method, uri, valueHandler);
	handle(request, deferred);
		
	shared HttpClientRequest timeout(Integer t) {
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