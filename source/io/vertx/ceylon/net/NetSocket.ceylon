import org.vertx.java.core.net { NetSocket_=NetSocket }
import io.vertx.ceylon { Chunk }
import org.vertx.java.core.buffer { Buffer_=Buffer }
import ceylon.promise { Promise, Deferred }
import io.vertx.ceylon.util { voidAsyncResult, VoidNullArgHandler }
import ceylon.io { SocketAddress }
import io.vertx.ceylon.stream { ReadStream, wrapWriteStream, WriteStream, wrapReadStream }

"""Represents a socket-like interface to a TCP/SSL connection on either the
   client or the server side.
   
   Instances of this class are created on the client side by an [[NetClient]]
   when a connection to a server is made, or on the server side by a [[NetServer]]
   when a server accepts a connection.
   
   It provides access to both [[readStream]] and [[writeStream]] so it can be used with
   [[io.vertx.ceylon.stream::Pump]] to pump data with flow control.
   
   Instances of this class are not thread-safe."""
shared class NetSocket(NetSocket_ delegate) {
  
  shared WriteStream writeStream = wrapWriteStream(delegate);
  
  shared ReadStream readStream = wrapReadStream(delegate);
  
  """When a [[NetSocket]] is created it automatically registers an event handler with the event bus, the ID of that
     handler is given by [[NetSocket.writeHandlerID]].
     
     Given this ID, a different event loop can send a buffer to that event handler using the event bus and
     that buffer will be received by this instance in its own event loop and written to the underlying connection. This
     allows you to write data to other connections which are owned by different event loops."""
  shared String writeHandlerID => delegate.writeHandlerID();
  
  "Write a [[Chunk]] to the request body."
  shared NetSocket write(Chunk chunk) {
    switch (chunk) 
    case (is String) {
      delegate.write(chunk);
    }
    case (is [String,String]) {
      delegate.write(chunk[0], chunk[1]);
    }
    case (is Buffer_) {
      delegate.write(chunk);
    }
    return this;
  }
  
  """Tell the kernel to stream a file as specified by [[fileName]]] directly, from disk to the
     outgoing connection, bypassing userspace altogether (where supported by the underlying
     operating system. This is a very efficient way to serve files."""
  shared Promise<Null> sendFile(String fileName) {
    value result = voidAsyncResult();
    delegate.sendFile(fileName, result);
    return result.promise;
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
  
  // Can't work
  // "Returns `true` if this [[NetSocket]] is encrypted via SSL/TLS."
  // shared Boolean ssl => delegate.ssl;
  
  "Upgrade channel to use SSL/TLS. Be aware that for this to work SSL must be configured."
  shared Promise<Null> sslUpgrade(void onUpgrade()) {
    value done = Deferred<Null>();
    delegate.ssl(VoidNullArgHandler(done.fulfill));
    return done.promise;
  }
  
  "Close the NetSocket"
  shared void close() => delegate.close();
}