import org.vertx.java.core.http { ServerWebSocket_=ServerWebSocket }
import io.vertx.ceylon {
  MultiMap
}
import io.vertx.ceylon.util {
  toMap
}

"""Represents a server side WebSocket that is passed into a the websocketHandler of an [[HttpServer]]
   
   Instances of this class are not thread-safe"""
shared class ServerWebSocket(ServerWebSocket_ delegate) extends WebSocketBase(delegate) {
  
  """The uri the websocket handshake occurred at"""
  shared String uri = delegate.uri();
  
  """The path the websocket is attempting to connect at"""
  shared String path = delegate.path();

  """The query string passed on the websocket uri"""
  shared String? query = delegate.query();

  // Lazy header map
  variable MultiMap? headerMap = null;

  """A map of all headers in the request to upgrade to websocket"""
  shared MultiMap headers {
    if (exists ret = headerMap) {
      return ret;
    } else {
      value headersMM = delegate.headers();
      return headerMap = toMap(headersMM);
    }
  }
  
  """Reject the WebSocket
     
     Calling this method from the websocketHandler gives you the opportunity to reject
     the websocket, which will cause the websocket handshake to fail by returning
     a `404` response code.
     
     You might use this method, if for example you only want to accept websockets
     with a particular path."""
  shared ServerWebSocket reject() {
    delegate.reject();
    return this;
  }
}