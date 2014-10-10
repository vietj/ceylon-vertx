import org.vertx.java.core {
  Handler_=Handler
}
import ceylon.promise {
  Deferred,
  Promise
}

by ("Julien Viet")
shared class HandlerPromise<Value,Result>(Value transform(Result? result))
    satisfies Handler_<Result> {
  
  Deferred<Value> deferred = Deferred<Value>();
  shared Promise<Value> promise = deferred.promise;
  
  shared actual void handle(Result? result) {
    try {
      value val = transform(result);
      deferred.fulfill(val);
    } catch (Exception e) {
      deferred.reject(e);
    }
  }
}
