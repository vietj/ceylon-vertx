import vietj.promises { Promise, Deferred }
import ceylon.test { ... }

import ceylon.net.uri { Uri, parseUri=parse }
import ceylon.net.http.client { Request, Response }

T assertResolve<T>(Promise<T>|Deferred<T> obj) {
	value future = Future<T>(obj);
	return future.get();
}

Response assertRequest(String uri, {<String->{String*}>*} headers = {}) {
	Uri tmp = parseUri(uri);
	Request req = Request(tmp);
	for (header in headers) {
		req.setHeader(header.key, *header.item);
	}
	return req.execute();
}

void run() {
	suite("vietj.vertx", "test utils" -> testUtils);
	suite("vietj.vertx", "test http server" -> testHttpServer);
	suite("vietj.vertx", "test event bus" -> testEventBus);
}