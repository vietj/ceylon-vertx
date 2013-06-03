import vietj.vertx { Vertx }
import vietj.vertx.http { HttpServer, HttpServerRequest, HttpServerResponse }
import ceylon.net.http { Header }
import ceylon.net.uri { Query, Parameter }
import ceylon.net.http.client { Response, Parser }
import ceylon.test { ... }
import vietj.promises { Promise, Deferred }
import ceylon.collection { HashMap }
import ceylon.io { newSocketConnector, SocketAddress }
import ceylon.io.charset { ascii }

void testHttpServer() {
	value vertx = Vertx();
	value server = vertx.createHttpServer();
	for (test in {testRequestHeaders,testPath,testQuery,testForm,test200}) {
		test(server);
		Promise<Null> promise = server.close();
		assertResolve(promise);
	}
}

void testPath(HttpServer server) {
	variable String? path = null;
	void f(HttpServerRequest req) {
		path = req.path;
		HttpServerResponse resp = req.response;
		resp.status(200);
		resp.contentType("text/html");
		resp.end("HELLO");
	}
	value a = server.requestHandler(f).listen(8080);
	assertResolve(a);
	assertRequest("http://localhost:8080/foo%20?bar");
	assertEquals("/foo ", path);
}

void testRequestHeaders(HttpServer server) {
	variable String? path = null;
	value headers = Deferred<Map<String, {String+}>>();
	void f(HttpServerRequest req) {
		path = req.path;
		headers.resolve(req.headers);
		HttpServerResponse resp = req.response;
		resp.status(200);
		resp.contentType("text/html");
		resp.end("HELLO");
	}
	assertResolve(server.requestHandler(f).listen(8080));
	/*
	assertRequest {
		uri = "http://localhost:8080/";
		headers = { "foo" -> {"foo_value"} };
	};
	*/

	// Do it by hand as the Ceylon client does not yet support POST
	value request = "GET / HTTP/1.1\r\nfoo: foo_value1\r\nfoo: foo_value2\r\n\r\n";
	value connector = newSocketConnector(SocketAddress("localhost", 8080));
	value socket = connector.connect();
	value buffer = ascii.encode(request);
	socket.writeFully(buffer);
	Parser(socket).parseResponse();
	socket.close();

	Map<String, {String+}> a = assertResolve(headers);
	assertEquals(HashMap({"foo"->{"foo_value1","foo_value2"}}), a);
}

void testQuery(HttpServer server) {
	variable Query? query = null;
	variable Map<String, {String+}>? parameters = null;
	void f(HttpServerRequest req) {
		query = req.query;
		parameters = req.queryParameters;
		HttpServerResponse resp = req.response;
		resp.status(200);
		resp.contentType("text/html");
		resp.end("HELLO");
	}
	assertResolve(server.requestHandler(f).listen(8080));
	assertRequest("http://localhost:8080/?foo=foo_value&bar=bar_value1&bar=bar_value2");
	assertEquals(Query(Parameter("foo", "foo_value"),  Parameter("bar", "bar_value1"), Parameter("bar", "bar_value2")), query);
	assertEquals(HashMap({"foo"->{"foo_value"},"bar"->{"bar_value1","bar_value2"}}), parameters);
}

void testForm(HttpServer server) {
	value parameters = Deferred<Map<String, {String+}>>();
	Promise<Map<String, {String+}>> p = parameters.promise;
	void f(HttpServerRequest req) {
		value form = req.formParameters;
		if (exists form) {
			parameters.resolve(form);
		} else {
			parameters.reject(Exception("No parameters"));
		}
		HttpServerResponse resp = req.response;
		resp.status(200);
		resp.contentType("text/html");
		resp.end("HELLO");
	}
	assertResolve(server.requestHandler(f).listen(8080));

	// Do it by hand as the Ceylon client does not yet support POST
	value request = "POST / HTTP/1.1\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 43\r\n\r\nfoo=foo_value&bar=bar_value1&bar=bar_value2";
	value connector = newSocketConnector(SocketAddress("localhost", 8080));
	value socket = connector.connect();
	value buffer = ascii.encode(request);
	socket.writeFully(buffer);
	Parser(socket).parseResponse();
	socket.close();
	value o = assertResolve(p);
	assertEquals(HashMap({"foo"->{"foo_value"},"bar"->{"bar_value1","bar_value2"}}), o);
}

void test200(HttpServer server) {
	void f(HttpServerRequest req) {
		HttpServerResponse resp = req.response;
		resp.status(200);
		resp.headers("foo"->"foo_value","bar"->"bar_value");
		resp.contentType("text/html");
		resp.end("HELLO");
	}
	assertResolve(server.requestHandler(f).listen(8080));
	Response resp = assertRequest("http://localhost:8080");
	assertEquals(200, resp.status);
	assertEquals("text/html", resp.contentType);
	assertEquals("UTF-8", resp.charset);
	assertEquals("HELLO", resp.contents);
	Header? foo = resp.headersByName["foo"];
	if (exists foo) {
		assertEquals({"foo_value"}, foo.values);
	} else {
		fail("Was expecting the foo header");
	}
	Header? bar = resp.headersByName["bar"];
	if (exists bar) {
		assertEquals({"bar_value"}, bar.values);
	} else {
		fail("Was expecting the bar header");
	}
}


