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

import io.vertx.ceylon.http { ... }
import ceylon.promises { ... }
import io.vertx.ceylon.eventbus { ... }

by("Julien Viet")
shared void run(){
	value vertx = Vertx();
	value server = vertx.createHttpServer();

    void handle(HttpServerRequest req) {
        req.response.
            contentType("text/html").
            end("<html><body>
                 <h1>Hello from Vert.x with Ceylon!</h1>
 
                 <h2>Method</h2>
                 <p>``req.method``</p>
                 <h2>Path</h2>               
                 <p>``req.path``</p>
                 <h2>Headers</h2>
                 <p>``req.headers``</p>
                 <h2>Parameters</h2>
                 <p>``req.params``</p>
                 <h2>Query</h2>
                 <p>``req.query``</p>
                 <h2>Form parameters</h2>
                 <p>``req.formAttributes else {}``</p>
 
                 <form action='/post' method='POST'>
                 <input type='text' name='foo'>
                 <input type='submit'>
                 </form>
 
                 </body></html>").close();

        vertx.eventBus.send("foo", "Request ``req.path`` from ``req.remoteAddress.address``");
    }

    // Bind http server
    Promise<HttpServer> http = server.requestHandler(handle).listen(8080);
    http.then_((HttpServer arg) => print("Http server bound on 8080"));

    // Register event bus for logging messages
    Registration registration = vertx.eventBus.registerHandler("foo", (Message<String> msg) => print(msg.body));
    registration.completed.then_((Null arg) => print("Event handler registered"));

    // Wait until both conditions are met to say we are fully started
    // registration.completed.and(http).then_((HttpServer server, Null n) => print("Application started"));

    //
    process.readLine();
    vertx.stop();
}


