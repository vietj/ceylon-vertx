import io.vertx.ceylon.core.http { ... }
import ceylon.promise { ... }
import io.vertx.ceylon.core.eventbus { ... }

by("Julien Viet")
shared void run2(){
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
 
                 <form action='/post' method='POST'>
                 <input type='text' name='foo'>
                 <input type='submit'>
                 </form>
 
                 </body></html>").close();

        vertx.eventBus.send("foo", "Request ``req.path`` from ``req.remoteAddress.address``");
    }

    // Bind http server
    Promise<HttpServer> http = server.requestHandler(handle).listen(8080);
    http.compose((HttpServer arg) => print("Http server bound on 8080"));

    // Register event bus for logging messages
    Registration registration = vertx.eventBus.registerHandler("foo", (Message<String> msg) => print(msg.body));
    registration.completed.compose((Null arg) => print("Event handler registered"));

    // Wait until both conditions are met to say we are fully started
    // registration.completed.and(http).then_((HttpServer server, Null n) => print("Application started"));

    //
    process.readLine();
    vertx.stop();
}


