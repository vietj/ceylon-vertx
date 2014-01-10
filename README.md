# Vert.x over Ceylon

Provides a Ceylon API for the Vert.x framework.

# Test Drive

    ceylon run vietj.vertx/0.3.8

This will execute the sample [sample](https://github.com/vietj/ceylon-vertx/blob/master/source/vietj/vertx/run.ceylon) server.

# Features

## HTTP bridging

    Vertx().createHttpServer().requestHandler(
        (HttpServerRequest req) => req.response.contentType("text/html").end("Hello World)
    ).listen(8080);

### HTTP Request bridge

    Map<String, {String+}> headers = req.headers;
    Map<String, {String+}> parameters = req.parameters;
    
### HTTP Response bridge
    
    req.response.headers("Content-Type" -> "text/html; charset=UTF-8");
    
or
    
    req.response.contentType("text/html");

### RouteMatcher

    value router = RouteMatcher();
    router.get("/animal/dogs", (HttpServerRequest req) => req.response.end(“You requested dogs"));
    router.get("/animal/cats", (HttpServerRequest req) => req.response.end(“You requested cats"));
    server.requestHandler(router.handle).listen(8080);

## EventBus bridging

    EventBus bus = Vertx().eventBus();

### send/publish

    bus.send("foo", "ping");

### Handlers

    bus.registerHandler("foo", (Message<String> msg) => msg.reply("pong"));

### Reply handler

    bus.send("foo", "ping", (Message<String> msg) => print("Got reply"));

### Event conversion

Now supports String and JSON.

## Uses Promises

    Promise<Registration> promise = bus.registerHandler(...);
    promise.then_((Registration reg) => print("Registered"), (Exception e) => print("Failed"));

