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

import org.vertx.java.core {
	VertxFactory { newVertx },
	Vertx_=Vertx
}
import vietj.vertx.http { HttpServer, HttpClient }
import vietj.vertx.eventbus { EventBus }

by "Julien Viet"
license "ASL2"
shared class Vertx(shared Integer? port = null, shared String? hostName = null) {
	
	// Create deleg
	Vertx_ v_;
	if (exists port) {
		if (exists hostName) {
  			v_ = newVertx(port, hostName);
		} else {
  			throw Exception("When port is provided, hostName must be too");
		}
	} else {
		if (exists hostName) {
  			v_ = newVertx(hostName);
		} else {
			v_ = newVertx();
		}
	}
	Vertx_ v = v_;
	
	@doc "The event bus"
	shared EventBus eventBus = EventBus(v.eventBus());
	
	shared HttpServer createHttpServer() {
		return HttpServer(v.createHttpServer());
	}
	
	shared HttpClient createHttpClient(Integer? port = null, String? hostName = null) {
		value client = v.createHttpClient();
		if (exists port) {
			client.setPort(port);
		}
		if (exists hostName) {
			client.setHost(hostName);
		}
		return HttpClient(client);
	}

		shared void stop() {
		v_.stop();
	}
}