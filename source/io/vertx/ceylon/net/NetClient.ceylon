import org.vertx.java.core.net { NetClient_=NetClient }
import io.vertx.ceylon { ClientBase }
import ceylon.promise { Promise }
import io.vertx.ceylon.util { AsyncResultPromise }

"""A TCP/SSL client.
   Multiple connections to different servers can be made using the same instance.
   
   This client supports a configurable number of connection attempts and a configurable
   delay between attempts.
   
   If an instance is instantiated from an event loop then the handlers
   of the instance will always be called on that same event loop.
   If an instance is instantiated from some other arbitrary Java thread (i.e. when using embedded) then
   an event loop will be assigned to the instance and used when any of its handlers
   are called.
   
   Instances of this class are thread-safe."""
shared class NetClient(NetClient_ delegate) extends ClientBase(delegate, delegate) {
  
  "Attempt to open a connection to a server at the specific [[port]] and [[host]].
   [[host]] can be a valid host name or IP address. The connect is done asynchronously and on success, a
   [[NetSocket]] instance is supplied via the returned promise"
  shared Promise<NetSocket> connect(Integer port, String? host = null) {
    value handler = AsyncResultPromise(NetSocket);
    if (exists host) {
      delegate.connect(port, host, handler);
    } else {
      delegate.connect(port, handler);
    }
    return handler.promise;
  }
  
  "Get the number of reconnect attempts"
  shared Integer reconnectAttempts => delegate.reconnectAttempts;
  
  "Set the number of reconnection attempts. In the event a connection attempt fails, the client will attempt
   to connect a further number of times, before it fails. Default value is zero."
  assign reconnectAttempts => delegate.setReconnectAttempts(reconnectAttempts);
  
  "Get the number of reconnect attempts"
  shared Integer reconnectInterval => delegate.reconnectInterval;
  
  "Set the reconnect interval, in milliseconds"
  assign reconnectInterval => delegate.setReconnectInterval(reconnectInterval);
  
  "The connect timeout in milliseconds"
  shared Integer connectTimeout => delegate.connectTimeout;
  
  "Close the client. Any sockets which have not been closed manually will be closed here."
  assign connectTimeout => delegate.setConnectTimeout(connectTimeout);
  
}