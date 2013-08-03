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

import org.vertx.java.core.http { HttpServerResponse_=HttpServerResponse }

by "Julien Viet"
license "ASL2"
doc "Represents a server-side HTTP response. Instances of this class are created and associated to every instance of
     [HttpServerRequest] that is created. It allows the developer to control the HTTP response that is sent back to the
     client for a particular HTTP request. It contains methods that allow HTTP  headers and trailers to be set, and
     for a body to be written out to the response.
     
     Instances of this class are not thread-safe."
shared class HttpServerResponse(HttpServerResponse_ delegate) extends HttpOutput<HttpServerResponse>() {

	doc "Set the status code."
	shared HttpServerResponse status(doc "the status code value" Integer code) {
		delegate.setStatusCode(code);
		return this;
  	}
  	
	shared actual HttpServerResponse header(String headerName, String headerValue) {
		delegate.putHeader(headerName, headerValue);
		return this;
	}

	shared actual HttpServerResponse end(String? chunk) {
		if (exists chunk) {
			delegate.end(chunk);
		} else {
			delegate.end();
		}
		return this;
	}

	shared actual HttpServerResponse headers(<String-><String|{String+}>>* headers) {
		for (header_ in headers) {
			value item = header_.item;
			switch (item)
				case (is String) {
					delegate.putHeader(header_.key, item);
				}
				case (is {String+}) { 
					throw Exception("Cannot be implemented now : ambiguous reference to overloaded method or class: putHeader");
				}
		}
		return this;
	}
}