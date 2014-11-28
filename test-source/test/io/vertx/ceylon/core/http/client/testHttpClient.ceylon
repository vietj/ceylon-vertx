import ceylon.promise {
  Promise
}
import io.vertx.ceylon.core {
  Vertx
}
import io.vertx.ceylon.core.http {
  ...
}
import ceylon.test {
  ...
}
import ceylon.io.charset {
  utf8,
  Charset
}
import ceylon.io.buffer {
  ByteBuffer
}
import org.vertx.java.core.buffer {
  Buffer
}
import test.io.vertx.ceylon.core {
  with,
  assertResolve,
  assertResolveTo
}

shared test
void testTimeout() => with {
  void test(Vertx vertx) {
    try {
      HttpClient client = vertx.createHttpClient(5000, "localhost");
      HttpClientRequest req = client.get("/foo").timeout(100);
      try {
        assertResolve(req.response, 10000);
        fail("Was expecting an exception");
      } catch (Exception ignore) {
        // Expected
      }
    } finally {
      vertx.stop();
    }
  }
};

shared test
void testRequest() => with {
  void test(Vertx vertx) {
    HttpServer server = vertx.createHttpServer();
    Promise<HttpServer> promise = server.requestHandler((HttpServerRequest req) => req.response.headers { "bar"->"bar_value" }.contentType("text/plain").end("foo_content").close()).listen(8080);
    assertEquals(server, assertResolve(promise, 10000));
    HttpClient client = vertx.createHttpClient(8080, "localhost");
    HttpClientRequest req = client.get("/foo");
    Promise<String> check(HttpClientResponse resp) {
      assertEquals(200, resp.statusCode);
      assertEquals(["bar_value"], resp.headers["bar"]);
      assertEquals("text/plain", resp.mimeType);
      assertEquals(utf8, resp.charset);
      return resp.parseBody(textBody);
    }
    Promise<String> body = req.response.flatMap<String>(check);
    req.contentType("text/plain").end("the_body");
    String ret = assertResolve(body, 10000);
    assertEquals("foo_content", ret);
  }
};

shared test
void testResponse() => with {
  void test(Vertx vertx) {
    HttpServer server = vertx.createHttpServer();
    Promise<HttpServer> promise = server.requestHandler((HttpServerRequest req) => req.response.headers { "bar"->"bar_value" }.end().close()).listen(8080);
    assertResolveTo(promise, server, 10000);
    HttpClient client = vertx.createHttpClient(8080, "localhost");
    HttpClientRequest req = client.get("/foo").end();
    HttpClientResponse ret = assertResolve(req.response, 10000);
    assertEquals(200, ret.statusCode);
    assertEquals(["bar_value"], ret.headers["bar"]);
  }
};

shared test
void testTextResponse() => with {
  void test(Vertx vertx) {
    HttpServer server = vertx.createHttpServer();
    Promise<HttpServer> promise = server.requestHandler((HttpServerRequest req) => req.response.contentType("text/plain").end("foo_content").close()).listen(8080);
    assertResolveTo(promise, server, 10000);
    HttpClient client = vertx.createHttpClient(8080, "localhost");
    HttpClientRequest req = client.get("/foo");
    Promise<String> check(HttpClientResponse resp) {
      assertEquals(200, resp.statusCode);
      assertEquals("text/plain", resp.mimeType);
      assertEquals(utf8, resp.charset);
      return resp.parseBody(textBody);
    }
    Promise<String> body = req.response.flatMap<String>(check);
    req.end();
    String ret = assertResolve(body, 10000);
    assertEquals("foo_content", ret);
  }
};

shared test
void testBinaryBody() => with {
  void test(Vertx vertx) {
    HttpServer server = vertx.createHttpServer();
    Promise<HttpServer> promise = server.requestHandler((HttpServerRequest req) => req.response.contentType("text/plain").end("ABC").close()).listen(8080);
    assertResolveTo(promise, server, 10000);
    HttpClient client = vertx.createHttpClient(8080, "localhost");
    HttpClientRequest req = client.get("/foo");
    Promise<ByteBuffer> check(HttpClientResponse resp) {
      assertEquals(200, resp.statusCode);
      assertEquals("text/plain", resp.mimeType);
      assertEquals(utf8, resp.charset);
      return resp.parseBody(binaryBody);
    }
    Promise<ByteBuffer> body = req.response.flatMap<ByteBuffer>(check);
    req.end();
    ByteBuffer ret = assertResolve(body, 10000);
    assertEquals(3, ret.size);
    assertEquals(Byte(65), ret.get());
    assertEquals(Byte(66), ret.get());
    assertEquals(Byte(67), ret.get());
  }
};

Promise<String> check(HttpClientResponse resp) {
  assertEquals(200, resp.statusCode);
  assertEquals("text/plain", resp.mimeType);
  assertEquals(utf8, resp.charset);
  return resp.parseBody {
    object parser satisfies BodyType<String> {
      shared actual Boolean accept(String mimeType) => true;
      shared actual String parse(Charset? charset, Buffer data) {
        throw Exception("the_failure");
      }
    }
  };
}

shared test
void testBodyParserFailure() => with {
  void test(Vertx vertx) {
    HttpServer server = vertx.createHttpServer();
    Promise<HttpServer> promise = server.requestHandler((HttpServerRequest req) => req.response.contentType("text/plain").end("ABC").close()).listen(8080);
    assertResolveTo(promise, server, 10000);
    HttpClient client = vertx.createHttpClient(8080, "localhost");
    HttpClientRequest req = client.get("/foo");
    Promise<String> body = req.response.flatMap<String>(check);
    req.end();
    try {
      assertResolve(body, 10000);
      fail("Was expecting a failure");
    } catch (Exception e) {
      // Expected
    }
  }
};
