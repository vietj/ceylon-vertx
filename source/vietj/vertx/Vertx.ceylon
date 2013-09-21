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

"The control centre of the Vert.x Core API.
 
 You should normally only use a single instance of this class throughout your application. If you are running in the
 Vert.x container an instance will be provided to you.
 
 This class acts as a factory for TCP/SSL and HTTP/HTTPS servers and clients, SockJS servers, and provides an
 instance of the event bus, file system and shared data classes, as well as methods for setting and cancelling
 timers.
 
 Create a new Vertx instance, when the `clusterPort` or the `clusterHost` is specified a clustered instance
 is created. Instances of this class are thread-safe."
by("Julien Viet")
shared class Vertx(
        "The port to listen for cluster connections"
        shared Integer? clusterPort = null,
        "The hostname or ip address to listen for cluster connection"
        shared String? clusterHost = null) {

    // Create deleg
    Vertx_ v_;
    if (exists clusterPort) {
        if (exists clusterHost) {
            v_ = newVertx(clusterPort, clusterHost);
        } else {
            throw Exception("When port is provided, hostName must be too");
        }
    } else {
        if (exists clusterHost) {
            v_ = newVertx(clusterHost);
        } else {
            v_ = newVertx();
        }
    }
    Vertx_ v = v_;

    "The event bus"
    shared EventBus eventBus = EventBus(v.eventBus());

    "Create a new http server and returns it"
    shared HttpServer createHttpServer() {
        return HttpServer(v.createHttpServer());
    }

    "Create a new http client and return it"
    shared HttpClient createHttpClient(
        "the client port"
        Integer? port = null,
        "the client host"
    String? host = null) {
        value client = v.createHttpClient();
        if (exists port) {
            client.setPort(port);
        }
        if (exists host) {
            client.setHost(host);
        }
        return HttpClient(client);
    }
    
    "Stop Vertx"
    shared void stop() {
        v_.stop();
    }
}