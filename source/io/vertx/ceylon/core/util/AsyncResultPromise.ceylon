import org.vertx.java.core {
  Handler_=Handler,
  AsyncResult_=AsyncResult
}
import ceylon.promise {
  Deferred,
  Promise,
  ExecutionContext
}
import java.lang {
  Void_=Void,
  Boolean_=Boolean,
  String_=String,
  ObjectArray_=ObjectArray
}
import io.vertx.ceylon.core.util {
  fromStringArray
}

by ("Julien Viet")
shared class AsyncResultPromise<Value,Result>(ExecutionContext context, Value(Result) transform)
    satisfies Handler_<AsyncResult_<Result>> {
  
  Deferred<Value> deferred = Deferred<Value>(context);
  shared Promise<Value> promise = deferred.promise;
  
  shared actual void handle(AsyncResult_<Result> asyncResult) {
    if (asyncResult.succeeded()) {
      value result = asyncResult.result();
      try {
        value val = transform(result);
        deferred.fulfill(val);
      } catch (Exception e) {
        deferred.reject(e);
      }
    } else {
      value cause = asyncResult.cause();
      deferred.reject(cause);
    }
  }
}

shared AsyncResultPromise<Boolean,Boolean_> booleanAsyncResult(ExecutionContext context) => AsyncResultPromise<Boolean,Boolean_>(context, (Boolean_ v) => v.booleanValue());
shared AsyncResultPromise<Anything,Void_> voidAsyncResult(ExecutionContext context) => AsyncResultPromise<Anything,Void_>(context, (Void_ v) => ""); // should use null
shared AsyncResultPromise<String,String_> stringAsyncResult(ExecutionContext context) => AsyncResultPromise<String,String_>(context, (String_ v) => v.string);
shared AsyncResultPromise<{String*},ObjectArray_<String_>> stringArrayAsyncResult(ExecutionContext context) => AsyncResultPromise<{String*},ObjectArray_<String_>>(context, fromStringArray);

shared AsyncResultPromise<Result,Result> asyncResult<Result>(ExecutionContext context) => AsyncResultPromise<Result,Result>(context, (Result result) => result);
