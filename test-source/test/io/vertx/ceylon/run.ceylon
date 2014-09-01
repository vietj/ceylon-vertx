import ceylon.promise { Promise, Deferred, Future }
import ceylon.test { ... }
import ceylon.test.core { DefaultLoggingListener }

import ceylon.net.uri { Uri, parseUri=parse }
import ceylon.net.http.client { Request, Response, Parser }
import test.io.vertx.ceylon.http.server { ... }
import test.io.vertx.ceylon.http.client { ... }
import test.io.vertx.ceylon.eventbus { ... }
import ceylon.io.charset { ascii }
import ceylon.io { newSocketConnector, SocketAddress }
import java.lang { ByteArray }
import io.vertx.ceylon { Vertx }
import io.vertx.ceylon.http { HttpServer }
import io.vertx.ceylon.shareddata { SharedData }
import io.vertx.ceylon.eventbus { EventBus }

shared void with(void test(Vertx vertx)) {
  value vertx = Vertx();
  try {
    test(vertx);
  } finally {
    vertx.stop();
  }
}

shared Anything(Vertx) server(void test(HttpServer server)) {
  void f(Vertx vertx) {
    value server = vertx.createHttpServer();
    test(server);
    Promise<Null> promise = server.close();
    assertResolve(promise);
  }
  return f;
}

shared Anything(Vertx) sharedData(void test(SharedData sharedData)) {
  void f(Vertx vertx) {
    test(vertx.sharedData);
  }
  return f;
}

shared Anything(Vertx) eventBus(void test(EventBus sharedData)) {
  void f(Vertx vertx) {
    test(vertx.eventBus);
  }
  return f;
}

shared T assertResolve<T>(Promise<T>|Deferred<T> obj) {
    Future<T> future;
    switch (obj)
    case (is Promise<T>) { future = obj.future; }
    case (is Deferred<T>) { future = obj.promise.future; }
    T|Throwable r = future.get(20000);
    if (is T r) {
        return r;
    } else if (is Exception r) {
        throw r;
    } else {
        throw Exception("Was not expecting this");
    }
}

shared Response assertRequest(String uri, {<String->{String*}>*} headers = {}) {
    Uri tmp = parseUri(uri);
    Request req = Request(tmp);
    for (header in headers) {
        req.setHeader(header.key, *header.item);
    }
    return req.execute();
}

shared Response assertSend(String data) {
    value connector = newSocketConnector(SocketAddress("localhost", 8080));
    value socket = connector.connect();
    value buffer = ascii.encode(data);
    socket.writeFully(buffer);
    value response = Parser(socket).parseResponse();
    value contents = response.contents; // Read before we close
    socket.close();
    return response;
}

shared ByteArray toByteArray({Integer*} seq) {
    value array = ByteArray(seq.size);
    variable Integer ptr = 0;
    for (i in seq) {
        array.set(ptr++, i.byte);
    }
    return array;
}

shared Boolean byteArrayEquals(ByteArray ba1, ByteArray ba2) {
    if (ba1.size == ba2.size) {
        for (i in 0..ba1.size-1) {
            if (ba1.get(i) != ba2.get(i)) {
                return false;
            }
        }
        return true;
    } else {
        return false;
    }
}

by("Julien Viet")
void run() {
    value runner = createTestRunner([`module test.io.vertx.ceylon`], [DefaultLoggingListener()]);
    value result = runner.run();
    print(result);
}