import vietj.promises { Promise, Deferred }
import java.util.concurrent { CountDownLatch, TimeUnit { seconds = \iSECONDS } }
import ceylon.test { ... }

import ceylon.net.uri { Uri, parseUri=parse }
import ceylon.net.http.client { Request, Response }

T assertResolve<T>(Promise<T>|Deferred<T> obj) {
	Promise<T> promise;
	if (is Promise<T> obj) {
		promise = obj;
	} else if (is Deferred<T> obj) {
		promise = obj.promise;
	} else {
		throw AssertException("Impossible");
	}
	CountDownLatch latch = CountDownLatch(1);
	variable Exception? failure = null;
	void report(Exception e) {
		failure = e;
		latch.countDown(); 
	}
	variable T? val = null;
	void foo(T t) {
		val = t;
		latch.countDown();
	}
	promise.then_(foo, report);
	if (latch.await(20, seconds)) {
		if (exists f = failure) {
			 throw f;
		} else {
			if (is T ret = val) {
				return ret;
			} else {
				throw AssertException("Impossible");
			}
		}
	} else {
		throw AssertException("Timed out waiting for :" + promise.hash.string);
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
}