import org.vertx.java.core.sockjs { SockJSSocket_=SockJSSocket }
import io.vertx.ceylon.stream { ReadStream, WriteStream,
  wrapWriteStream,
  wrapReadStream }
import ceylon.io {
  SocketAddress
}
import io.vertx.ceylon {
  MultiMap
}
import io.vertx.ceylon.util {
  toMap
}

"""You interact with SockJS clients through instances of SockJS socket.
   
   The API is very similar to [[io.vertx.ceylon.http::WebSocket]]].
   It provides access to both [[SockJSSocket.readStream]] and [[SockJSSocket.writeStream]] so it can be used with
   [[io.vertx.ceylon.stream::Pump]] to pump data with flow control.
   
   Instances of this class are not thread-safe."""
shared class SockJSSocket(SockJSSocket_ delegate) {
  
  shared WriteStream writeStream = wrapWriteStream(delegate);
  
  shared ReadStream readStream = wrapReadStream(delegate);
  
  """When a `SockJSSocket` is created it automatically registers an event handler with the event bus,
     the ID of that handler is given by `writeHandlerID`.
     
     Given this ID, a different event loop can send a buffer to that event handler using the event bus and
     that buffer will be received by this instance in its own event loop and written to the underlying socket.
     This allows you to write data to other sockets which are owned by different event loops."""
  shared String writeHandlerID => delegate.writeHandlerID();
  
  "Return the URI corresponding to the last request for this socket or the websocket handshake"
  shared String uri => delegate.uri();
  
  // Lazy header map
  variable MultiMap? headerMap = null;
  
  """Return the headers corresponding to the last request for this socket or the websocket handshake
     Any cookie headers will be removed for security reasons"""
  shared MultiMap headers {
    if (exists ret = headerMap) {
      return ret;
    } else {
      value headersMM = delegate.headers();
      return headerMap = toMap(headersMM);
    }
  }
  
  "Close it"
  shared void close() {
    delegate.close();
  }
  
  """Return the remote address for this socket"""
  shared SocketAddress remoteAddress {
    value address = delegate.remoteAddress();
    return SocketAddress(address.address.hostAddress, address.port);
  }
  
  """Return the local address for this socket"""
  shared SocketAddress localAddress {
    value address = delegate.localAddress();
    return SocketAddress(address.address.hostAddress, address.port);
  }
}

class SockJSSocketImpl(shared SockJSSocket_ delegate) extends SockJSSocket(delegate) {
}