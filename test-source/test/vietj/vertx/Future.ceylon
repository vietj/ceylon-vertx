import vietj.promises { Promise, Deferred }
import java.util.concurrent { CountDownLatch, TimeUnit { seconds = \iSECONDS } }
import ceylon.test { ... }

class Future<Value>(Deferred<Value>|Promise<Value> obj = Deferred<Value>()) {
	
	Promise<Value> promise;
	if (is Promise<Value> obj) {
		promise = obj;
	} else if (is Deferred<Value> obj) {
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
	variable Value? val = null;
	void foo(Value t) {
		val = t;
		latch.countDown();
	}
	promise.then_(foo, report);
	
	shared void set(Value val) {
		if (is Deferred<Value> obj) {
			obj.resolve(val);
		} else {
			throw AssertException("Cannot resolve non deferred object");
		}
	}
	
	shared Value get(Integer timeOut = 20) {
		if (latch.await(timeOut, seconds)) {
			if (exists f = failure) {
				 throw f;
			} else {
				if (is Value ret = val) {
					return ret;
				} else {
					throw AssertException("Impossible");
				}
			}
		} else {
			throw AssertException("Timed out waiting for :" + promise.hash.string);
		}
	}
	
}