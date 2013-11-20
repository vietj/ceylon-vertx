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
import java.lang { Void_=Void }
import vietj.vertx.util { HandlerPromise, toMap }

"An HTTP and WebSockets server

 If an instance is instantiated from an event loop then the handlers of the instance will
 always be called on that same event loop. If an instance is instantiated from some other
 arbitrary Java thread then an event loop will be assigned to the instance and used when
 any of its handlers are called.
 
 Instances of HttpServer are thread-safe."
by("Julien Viet")
shared class HttpServer(HttpServer_ delegate) {
	
	"Set the request handler for the server to `requestHandler`. As HTTP requests are received by the server,
     instances of [[HttpServerRequest]] will be created and passed to this handler."
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
							requestHandler(HttpServerRequest(delegate, form));
						}
					} 
					delegate.expectMultiPart(true);
					delegate.endHandler(handler); 
				} else {
					
					// We must pause
					delegate.pause();
					
					//
					requestHandler(HttpServerRequest(delegate));
				}
			}
		}
		delegate.requestHandler(handler);
		return this;
	}

    "Tell the server to start listening on all available interfaces and port `port`.
     Be aware this is an async operation and the server may not bound on return of the method.
     The returned promise is resolved when the server is listening"
    shared Promise<HttpServer> listen(Integer port, String? hostName = null) {
        value server = this;
        value handler = HandlerPromise<HttpServer, HttpServer_>(
            (HttpServer_ s) => server);
        if (exists hostName) {
            delegate.listen(port, hostName, handler);
        } else {
            delegate.listen(port, handler);
        }
        return handler.promise;
    }

    "Close the server. Any open HTTP connections will be closed.
     The returned promise is resolved when the close is complete."	
    shared Promise<Null> close() {
        value handler = HandlerPromise<Null, Void_>((Void_ v) => null);
        delegate.close(handler);
        return handler.promise;
    }

}