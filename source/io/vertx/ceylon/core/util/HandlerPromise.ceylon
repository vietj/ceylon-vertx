import org.vertx.java.core {
  Handler_=Handler
}
import ceylon.promise {
  Deferred,
  Promise,
  ExecutionContext
}

by ("Julien Viet")
shared class HandlerPromise<Value,Result>(ExecutionContext context, Value transform(Result? result))
    satisfies Handler_<Result> {
  
  Deferred<Value> deferred = Deferred<Value>(context);
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
