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
import vietj.promises { Promise }
import vietj.vertx { Vertx }
import vietj.vertx.http { ... }
import ceylon.test { ... }
import ceylon.io.charset { utf8 }
import vietj.vertx.eventbus { EventBus }
import ceylon.io.buffer { ByteBuffer }

shared test void testTimeout() {
    Vertx vertx = Vertx();
    try {
        HttpClient client = vertx.createHttpClient(5000, "localhost");
        HttpClientRequest req = client.request("GET", "/foo").timeout(100);
        HttpClientResponse|Exception f = req.response.future.get(10000);
        if (is HttpClientResponse f) {
            fail("Was expecting an exception");
        }
    } finally {
        vertx.stop();
    }
}

shared test void testRequest() {
    Vertx vertx = Vertx();
    try {
        HttpServer server = vertx.createHttpServer();
        Promise<HttpServer> promise = server.
                requestHandler((HttpServerRequest req) => req.response.headers("bar"->"bar_value").contentType("text/plain").end("foo_content")).
                listen(8080);
        assertEquals(server, promise.future.get(10000));
        HttpClient client = vertx.createHttpClient(8080, "localhost");
        HttpClientRequest req = client.request("GET", "/foo").contentType("text/plain").end("the_body");
        HttpClientResponse|Exception ret = req.response.future.get(10000);
        if (is HttpClientResponse ret) {
            assertEquals(200, ret.status);
            assertEquals({"bar_value"}, ret.headers["bar"]);
            assertEquals("text/plain", ret.mimeType);
            assertEquals(utf8, ret.charset);
            Promise<String> body = ret.parseBody(textBody);
            assertEquals("foo_content", body.future.get(10000));
        } else {
            fail("Was expecting a response");
        }
    } finally {
        vertx.stop();
    }
}

shared test void testResponse() {
	Vertx vertx = Vertx();
	try {
		HttpServer server = vertx.createHttpServer();
		Promise<HttpServer> promise = server.
				requestHandler((HttpServerRequest req)
				=> req.response.
				headers("bar"->"bar_value").
				end()).
				listen(8080);
		assertEquals(server, promise.future.get(10000));
		HttpClient client = vertx.createHttpClient(8080, "localhost");
		HttpClientRequest req = client.request("GET", "/foo").end();
		HttpClientResponse|Exception ret = req.response.future.get(10000);
		if (is HttpClientResponse ret) {
			assertEquals(200, ret.status);
			assertEquals({"bar_value"}, ret.headers["bar"]);
		} else {
			fail("Was expecting a response");
		}
	} finally {
		vertx.stop();
	}
}
shared test void testTextResponse() {
    Vertx vertx = Vertx();
    try {
        HttpServer server = vertx.createHttpServer();
        Promise<HttpServer> promise = server.
                requestHandler((HttpServerRequest req)
                    => req.response.
                        contentType("text/plain").
                        end("foo_content")).
                listen(8080);
        assertEquals(server, promise.future.get(10000));
        HttpClient client = vertx.createHttpClient(8080, "localhost");
        HttpClientRequest req = client.request("GET", "/foo").end();
        HttpClientResponse|Exception ret = req.response.future.get(10000);
        if (is HttpClientResponse ret) {
            assertEquals(200, ret.status);
            assertEquals("text/plain", ret.mimeType);
            assertEquals(utf8, ret.charset);
            Promise<String> body = ret.parseBody(textBody);
            assertEquals("foo_content", body.future.get(10000));
        } else {
            fail("Was expecting a response");
        }
    } finally {
        vertx.stop();
    }
}

shared test void testBinaryBody() {
	Vertx vertx = Vertx();
	try {
		HttpServer server = vertx.createHttpServer();
		Promise<HttpServer> promise = server.
				requestHandler((HttpServerRequest req)
				=> req.response.
				contentType("text/plain").
				end("ABC")).
				listen(8080);
		assertEquals(server, promise.future.get(10000));
		HttpClient client = vertx.createHttpClient(8080, "localhost");
		HttpClientRequest req = client.request("GET", "/foo").end();
		HttpClientResponse|Exception ret = req.response.future.get(10000);
		if (is HttpClientResponse ret) {
			assertEquals(200, ret.status);
			assertEquals("text/plain", ret.mimeType);
			assertEquals(utf8, ret.charset);
			Promise<ByteBuffer> body = ret.parseBody(binaryBody);
			value buffer = body.future.get(10000);
			assert(is ByteBuffer buffer);
			assertEquals(3, buffer.size);
			assertEquals(65, buffer.get());
			assertEquals(66, buffer.get());
			assertEquals(67, buffer.get());
		} else {
			fail("Was expecting a response");
		}
	} finally {
		vertx.stop();
	}
}
