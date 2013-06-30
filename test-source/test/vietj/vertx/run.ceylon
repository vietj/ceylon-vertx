import vietj.promises { Promise, Deferred, Future }
import ceylon.test { ... }

import ceylon.net.uri { Uri, parseUri=parse }
import ceylon.net.http.client { Request, Response }

T assertResolve<T>(Promise<T>|Deferred<T> obj) {
	Future<T> future;
	switch (obj)
	case (is Promise<T>) { future = obj.future; }
	case (is Deferred<T>) { future = obj.promise.future; }
	T|Exception r = future.get(20000);
	if (is T r) {
	  return r;
	} else if (is Exception r) {
	  throw r;
	} else {
	  throw Exception("Was not expecting this");
	}
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
	suite("vietj.vertx", "test http client" -> testHttpClient);
}