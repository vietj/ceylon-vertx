import org.vertx.java.core.http { WebSocketBase_=WebSocketBase, WebSocketFrame_=WebSocketFrame }
import org.vertx.java.core.buffer { Buffer }
import io.vertx.ceylon.util { FunctionalHandlerAdapter, HandlerPromise }
import ceylon.io { SocketAddress }
import io.vertx.ceylon.stream { WriteStream, ReadStream }
import java.lang { Void_=Void }
import ceylon.promise { Promise }

"""Represents an HTML 5 Websocket
   
   Instances of this class are created and provided to the handler of an
   [[HttpClient]] when a successful websocket connect attempt occurs.
   
   
   On the server side, the subclass [[ServerWebSocket]] is used instead.
   
   
   It provides access to both [[io.vertx.ceylon.stream::ReadStream]] and [[io.vertx.ceylon.stream::WriteStream]] so
   it can be used with [[io.vertx.ceylon.stream::Pump]] to pump data with flow control.
   
   Instances of this class are not thread-safe"""
shared abstract class WebSocketBase(WebSocketBase_<out Object> delegate) {
  
  value closed = HandlerPromise<Null, Void_>((Void_? v) => null);
  delegate.closeHandler(closed);

  shared WriteStream writeStream = WriteStream(delegate);
  
  shared ReadStream readStream = ReadStream(delegate);

  """When a [[WebSocket]] is created it automatically registers an event handler with the eventbus, the ID of that
     handler is given by `binaryHandlerID`.
     
     Given this ID, a different event loop can send a binary frame to that event handler using the event bus and
     that buffer will be received by this instance in its own event loop and written to the underlying connection. This
     allows you to write data to other websockets which are owned by different event loops."""
  shared String binaryHandlerId = delegate.binaryHandlerID();
  
  """When a [[WebSocket]] is created it automatically registers an event handler with the eventbus, the ID of that
     handler is given by `textHandlerID`.
     
     Given this ID, a different event loop can send a text frame to that event handler using the event bus and
     that buffer will be received by this instance in its own event loop and written to the underlying connection. This
     allows you to write data to other websockets which are owned by different event loops."""
  shared String textHandlerID = delegate.textHandlerID();
  
  """Write `data` to the websocket as a binary frame"""
  shared WebSocketBase writeBinaryFrame(Buffer buffer) {
    delegate.writeBinaryFrame(buffer);
    return this;
  }
  
  """Write `str` to the websocket as a text frame"""
  shared WebSocketBase writeTextFrame(String str) {
    delegate.writeTextFrame(str);
    return this;
  }
  
  shared Promise<Null> closeHandler() {
    return closed.promise;
  }
  
  """Set a frame handler on the connection"""
  shared WebSocketBase frameHandler(void onFrame(WebSocketFrame frame)) {
    value adapter = FunctionalHandlerAdapter<WebSocketFrame, WebSocketFrame_>(WebSocketFrame, onFrame);
    delegate.frameHandler(adapter);
    return this;
  }
  
  """Close the websocket"""
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