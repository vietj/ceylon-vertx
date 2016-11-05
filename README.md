# Vert.x over Ceylon

Provides a Ceylon API for the Vert.x framework.

Please see the much improved, official Ceylon.support for Vert.x [here](https://github.com/vert-x3/vertx-lang-ceylon).

# Documentation

Documentation can be found [here](https://modules.ceylon-lang.org/repo/1/io/vertx/ceylon/0.3.10/module-doc/index.html)

# Test Drive

    ceylon run vietj.vertx/0.3.10

This will execute the sample [sample](https://github.com/vietj/ceylon-vertx/blob/master/source/vietj/vertx/run.ceylon) server.

# Features

## HTTP

    Vertx().createHttpServer().requestHandler(
        (HttpServerRequest req) => req.response.contentType("text/html").end("Hello World)
    ).listen(8080);

### HTTP Request

    Map<String, {String+}> headers = req.headers;
    Map<String, {String+}> parameters = req.parameters;
    
### HTTP Response
    
    req.response.headers("Content-Type" -> "text/html; charset=UTF-8");
    
or
    
    req.response.contentType("text/html");

### RouteMatcher

    value router = RouteMatcher();
    router.get("/animal/dogs", (HttpServerRequest req) => req.response.end(“You requested dogs"));
    router.get("/animal/cats", (HttpServerRequest req) => req.response.end(“You requested cats"));
    server.requestHandler(router.handle).listen(8080);

## Shared Data

### Shared maps

    SharedMap<String, Integer> map = vertx.sharedData.getMap("demo.mymap");
    map.put("some-key", 123);

### Shared sets

    SharedSet<String> set = vertx.sharedData.getSet("demo.myset");
    set.add("some-value");

## Timers

### One shot timers

    value timerId = vertx.setTimer(1000, (Integer timerId) => print("And one second later this is printed"));
    print("First this is printed");

### Periodic timers

    value timerId = vertx.setTimer(1000, (Integer timerId) => print("And every second this is printed"));
    print("First this is printed");

## EventBus

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
    promise.onComplete((Registration reg) => print("Registered"), (Exception e) => print("Failed"));

