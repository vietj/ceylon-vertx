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

import org.vertx.java.core.http { HttpServer_=HttpServer, HttpServerRequest_=HttpServerRequest }
import org.vertx.java.core { Handler_=Handler}
import vietj.promises { Promise }
import vietj.vertx { toMap }
import java.lang { Void_=Void }
import vietj.vertx { HandlerPromise }

by "Julien Viet"
license "ASL2"
shared class HttpServer(HttpServer_ delegate) {
	
	shared HttpServer requestHandler(Anything(HttpServerRequest) requestHandler) {
		object handler satisfies Handler_<HttpServerRequest_> {
			shared actual void handle(HttpServerRequest_ delegate) {
				
				//
				String? contentType = delegate.headers().get("Content-Type");
				if (exists contentType, contentType.lowercased.startsWith("application/x-www-form-urlencoded")) {
					// Need to parse form parameters
					object handler satisfies Handler_<Void_> {
						shared actual void handle(Void_ nothing) {
							value attributes = delegate.formAttributes();
							Map<String, {String+}> form = toMap(attributes);
							try {
								requestHandler(HttpServerRequest(delegate, form));
							} finally {
								delegate.response().close();
							}
						}
					} 
					delegate.endHandler(handler); 
				} else {
					
					// We must pause
					delegate.pause();
					
					//
					try {
						requestHandler(HttpServerRequest(delegate));
					} finally {
						delegate.response().close();
					}
				}
			}
		}
		delegate.requestHandler(handler);
		return this;
	}
	
	shared Promise<Null> listen(Integer port, String? hostName = null) {
		value handler = HandlerPromise<Null, HttpServer_>((HttpServer_ s) => null);
		if (exists hostName) {
			delegate.listen(port, hostName, handler);
		} else {
			delegate.listen(port, handler);
		}
		return handler.promise;
	}
	
	shared Promise<Null> close() {
		value handler = HandlerPromise<Null, Void_>((Void_ v) => null);
		delegate.close(handler);
		return handler.promise;
	}
}