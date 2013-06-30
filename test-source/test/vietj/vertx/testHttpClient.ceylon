import vietj.promises { Promise }
import vietj.vertx { Vertx }
import vietj.vertx.http { ... }
import ceylon.test { ... }
import ceylon.io.charset { utf8 }


void testHttpClient() {
	testTimeout();
	testRequest();
	testResponse();
}

void testTimeout() {
	Vertx vertx = Vertx();
	try {
		HttpClient client = vertx.createHttpClient(5000, "localhost");
		HttpClientRequest req = client.request("GET", "/foo").timeout(100);
		HttpClientResponse|Exception f = req.promise.future.get(10000);
		if (is HttpClientResponse f) {
			fail("Was expecting an exception");
		}
	} finally {
		vertx.stop();
	}
}

void testRequest() {
	Vertx vertx = Vertx();
	try {
		
		Promise<Null> promise = vertx.
			createHttpServer().
			requestHandler((HttpServerRequest req) => req.response.headers("bar"->"bar_value").contentType("text/plain").end("foo_content")).
			listen(8080);
		assertNull(promise.future.get(10000));
		HttpClient client = vertx.createHttpClient(8080, "localhost");
		HttpClientRequest req = client.request("GET", "/foo").contentType("text/plain").end("the_body");
		HttpClientResponse|Exception ret = req.promise.future.get(10000);
		if (is HttpClientResponse ret) {
			assertEquals(200, ret.status);
			assertEquals({"bar_value"}, ret.headers["bar"]);
			assertEquals("text/plain", ret.mimeType);
			assertEquals(utf8, ret.charset);
			Promise<String> body = ret.getBody(textBody);
			assertEquals("foo_content", body.future.get(10000));
		} else {
			fail("Was expecting a response");
		}
	} finally {
		vertx.stop();
	}
}

void testResponse() {
	Vertx vertx = Vertx();
	try {
		
		Promise<Null> promise = vertx.
			createHttpServer().
			requestHandler((HttpServerRequest req) => req.response.headers("bar"->"bar_value").contentType("text/plain").end("foo_content")).
			listen(8080);
		assertNull(promise.future.get(10000));
		HttpClient client = vertx.createHttpClient(8080, "localhost");
		HttpClientRequest req = client.request("GET", "/foo").end();
		HttpClientResponse|Exception ret = req.promise.future.get(10000);
		if (is HttpClientResponse ret) {
			assertEquals(200, ret.status);
			assertEquals({"bar_value"}, ret.headers["bar"]);
			assertEquals("text/plain", ret.mimeType);
			assertEquals(utf8, ret.charset);
			Promise<String> body = ret.getBody(textBody);
			assertEquals("foo_content", body.future.get(10000));
		} else {
			fail("Was expecting a response");
		}
	} finally {
		vertx.stop();
	}
}
