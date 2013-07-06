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
shared class HttpServerResponse(HttpServerResponse_ delegate) satisfies HttpOutput {

	shared HttpServerResponse status(Integer code) {
		delegate.setStatusCode(code);
		return this;
  	}

	shared actual HttpServerResponse contentType(String mimeType, String charset) {
		return headers("Content-Type" -> "``mimeType``; charset=``charset``");
	}
	
	shared HttpServerResponse headers(<String-><String|{String+}>>* headers) {
		for (header in headers) {
			value item = header.item;
			switch (item)
				case (is String) { delegate.putHeader(header.key, item); }
				case (is {String+}) { 
					throw Exception("Cannot be implemented now : ambiguous reference to overloaded method or class: putHeader");
				}
		}
		return this;
	}
	
	shared HttpServerResponse end(String? chunk = null) {
		if (exists chunk) {
			delegate.end(chunk);
		} else {
			delegate.end();
		}
		return this;
	}

}