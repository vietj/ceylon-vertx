import ceylon.promise { Deferred, Promise }
import org.vertx.java.core { Handler_=Handler }
import ceylon.io.charset { Charset }
import org.vertx.java.core.streams { ReadStream_=ReadStream }
import io.vertx.ceylon.core.util { functionalHandler }
import org.vertx.java.core.buffer { Buffer }

"Parse the body of an input"
Promise<Body> doParseBody<Body, T>(
  BodyType<Body> bodyType,
  Anything(Handler_<Buffer>) setBodyHandler,
  ReadStream_<T> stream,
  Charset? charset) {
  
  //
  Deferred<Body> deferred = Deferred<Body>();
  
  //
  object valueHandler satisfies Handler_<Buffer> {
    shared actual void handle(Buffer buffer) {
      try {
        Body body = bodyType.parse(charset, buffer);
        deferred.fulfill(body);
      } catch(Exception e) {
        deferred.reject(e);
      }
    }
  }
  
  // Set handlers
  setBodyHandler(valueHandler);
  stream.exceptionHandler(functionalHandler<Throwable>(deferred.reject));
  
  //
  return deferred.promise;
}
