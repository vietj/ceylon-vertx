import org.vertx.java.core {
  Handler_=Handler,
  AsyncResult_=AsyncResult
}
import ceylon.promise {
  Deferred,
  Promise
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
shared class AsyncResultPromise<Value,Result>(Value(Result) transform)
    satisfies Handler_<AsyncResult_<Result>> {
  
  Deferred<Value> deferred = Deferred<Value>();
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

shared AsyncResultPromise<Boolean,Boolean_> booleanAsyncResult() => AsyncResultPromise<Boolean,Boolean_>((Boolean_ v) => v.booleanValue());
shared AsyncResultPromise<Anything,Void_> voidAsyncResult() => AsyncResultPromise<Anything,Void_>((Void_ v) => ""); // should use null
shared AsyncResultPromise<String,String_> stringAsyncResult() => AsyncResultPromise<String,String_>((String_ v) => v.string);
shared AsyncResultPromise<{String*},ObjectArray_<String_>> stringArrayAsyncResult() => AsyncResultPromise<{String*},ObjectArray_<String_>>(fromStringArray);

shared AsyncResultPromise<Result,Result> asyncResult<Result>() => AsyncResultPromise<Result,Result>((Result result) => result);
