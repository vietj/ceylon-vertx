import ceylon.promise {
  Promise,
  Deferred
}
import ceylon.test {
  ...
}
import ceylon.test.core {
  DefaultLoggingListener
}
import ceylon.net.uri {
  Uri,
  parseUri=parse
}
import ceylon.net.http.client {
  Request,
  Response,
  Parser
}
import test.io.vertx.ceylon.core.http.server {
  ...
}
import test.io.vertx.ceylon.core.http.client {
  ...
}
import test.io.vertx.ceylon.core.eventbus {
  ...
}
import ceylon.io.charset {
  ascii
}
import ceylon.io {
  newSocketConnector,
  SocketAddress
}
import java.lang {
  ByteArray
}
import io.vertx.ceylon.core {
  Vertx
}
import io.vertx.ceylon.core.http {
  HttpServer
}
import io.vertx.ceylon.core.shareddata {
  SharedData
}
import io.vertx.ceylon.core.eventbus {
  EventBus
}
import io.vertx.ceylon.core.net {
  NetServer
}
import java.util.concurrent { CountDownLatch, TimeUnit }
import io.netty.util {
  Timeout
}

shared void with(void test(Vertx vertx)) {
  value vertx = Vertx();
  try {
    test(vertx);
  } finally {
    vertx.stop();
  }
}

shared Anything(Vertx) netServer(void test(NetServer server)) {
  void f(Vertx vertx) {
    value server = vertx.createNetServer();
    test(server);
    Promise<Anything> promise = server.close();
    assertResolve(promise);
  }
  return f;
}

shared Anything(Vertx) httpServer(void test(HttpServer server)) {
  void f(Vertx vertx) {
    value server = vertx.createHttpServer();
    test(server);
    Promise<Anything> promise = server.close();
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

shared void assertResolveTo<T>(Promise<T>|Deferred<T> obj, T expected, Integer timeout = 20000) {
  T ret = assertResolve(obj, timeout);
  assertEquals(ret, expected);
}

shared T assertResolve<T>(Promise<T>|Deferred<T> obj, Integer timeout = 20000) {
  Promise<T> future;
  switch (obj)
  case (is Promise<T>) {
    future = obj;
  }
  case (is Deferred<T>) {
    future = obj.promise;
  }
  variable Anything result = null;
  value latch = CountDownLatch(1);
  future.onComplete {
    void onFulfilled(T val) {
      result = val;
      latch.countDown();
    }
    void onRejected(Throwable t) {
      result = t;
      latch.countDown();
    }
  };
  latch.await(timeout, TimeUnit.\iMILLISECONDS);
  if (is T ret = result) {
    return ret;
  } else if (is Exception failure = result) {
    throw failure;
  } else {
    throw Exception("Callback timeout");
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

by ("Julien Viet")
void run() {
  value runner = createTestRunner([`module test.io.vertx.ceylon.core`], [DefaultLoggingListener()]);
  value result = runner.run();
  print(result);
}
