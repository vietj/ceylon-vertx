import io.vertx.ceylon.core.util {
  toMap
}
import ceylon.promise {
  Promise
}
import org.vertx.java.core.http {
  HttpClientResponse_=HttpClientResponse
}
import io.vertx.ceylon.core.stream {
  ReadStream
}
import ceylon.collection {
  LinkedList
}
import io.vertx.ceylon.core {
  MultiMap,
  Vertx
}
import io.vertx.ceylon.core.net {
  NetSocket
}

"Represents a client-side HTTP response. Instances of this class are not thread-safe."
by ("Julien Viet")
shared class HttpClientResponse(Vertx vertx, HttpClientResponse_ delegate)
    extends HttpInput() {
  
  variable NetSocket? cachedNetSocket = null;
  
  "The HTTP status code of the response"
  shared Integer statusCode => delegate.statusCode();
  
  "The HTTP status code of the response"
  shared String statusMessage => delegate.statusMessage();
  
  "The http headers"
  shared actual MultiMap headers = toMap(delegate.headers());
  
  "The http trailers"
  shared MultiMap trailers = toMap(delegate.trailers());
  
  "The Set-Cookie headers (including trailers)"
  shared {String*} cookies {
    LinkedList<String> b = LinkedList<String>();
    value i = delegate.cookies().iterator();
    while (i.hasNext()) {
      b.add(i.next().string);
    }
    return b;
  }
  
  shared actual ReadStream stream = ReadStream(delegate);
  
  shared actual Promise<Body> parseBody<Body>(BodyType<Body> parser) {
    return doParseBody(vertx.executionContext, parser, delegate.bodyHandler, delegate, charset);
  }
  
  shared actual NetSocket netSocket() {
    if (exists ns = cachedNetSocket) {
      return ns;
    } else {
      return cachedNetSocket = NetSocket(vertx, delegate.netSocket());
    }
  }
}
