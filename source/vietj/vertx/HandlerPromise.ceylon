import org.vertx.java.core { Handler_=Handler, AsyncResult_=AsyncResult }
import vietj.promises { Deferred, Promise }

shared class HandlerPromise<Value, Result>(Value(Result) transform) satisfies Handler_<AsyncResult_<Result>>  {
	
	Deferred<Value> deferred = Deferred<Value>();
	shared Promise<Value> promise = deferred.promise;
	
	shared actual void handle(AsyncResult_<Result> asyncResult) {
		if (asyncResult.succeeded()) {
			value result = asyncResult.result();
			try {
				value val = transform(result);
				deferred.resolve(val);
			} catch(Exception e) {
				deferred.reject(e);
			}
		} else {
			value cause = asyncResult.cause();
			deferred.reject(cause);
		}
	}
}