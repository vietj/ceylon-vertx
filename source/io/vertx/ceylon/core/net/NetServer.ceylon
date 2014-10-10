import org.vertx.java.core.net {
  NetServer_=NetServer
}
import io.vertx.ceylon.core {
  ServerBase
}
import io.vertx.ceylon.core.util {
  FunctionalHandlerAdapter,
  AsyncResultPromise,
  voidAsyncResult
}
import ceylon.promise {
  Promise
}

"""Represents a TCP or SSL server
   
   If an instance is instantiated from an event loop then the handlers
   of the instance will always be called on that same event loop.
   If an instance is instantiated from some other arbitrary Java thread (i.e. when running embedded) then
   and event loop will be assigned to the instance and used when any of its handlers
   are called.
   
   Instances of this class are thread-safe."""
shared class NetServer(NetServer_ delegate) extends ServerBase(delegate, delegate) {
  
  "The actual port the server is listening on. This is useful if you bound the server specifying 0 as port number
   signifying an ephemeral port"
  shared Integer port => delegate.port();
  
  "The host"
  shared String host => delegate.host();
  
  "Supply a connect handler for this server. The server can only have at most one connect handler at any one time.
   As the server accepts TCP or SSL connections it creates an instance of [[NetSocket]] and passes it to the
   [[onConnect]] handler."
  shared NetServer connectHandler(void onConnect(NetSocket sock)) {
    value adapter = FunctionalHandlerAdapter(NetSocket, onConnect);
    delegate.connectHandler(adapter);
    return this;
  }
  
  "Instruct the server to listen for incoming connections on the specified [[port]] and [[host]]. [[host]] can
     be a host name or an IP address."
  shared Promise<NetServer> listen(Integer port, String? host = null) {
    value server = this;
    value handler = AsyncResultPromise((NetServer_ s) => server);
    if (exists host) {
      delegate.listen(port, host, handler);
    } else {
      delegate.listen(port, handler);
    }
    return handler.promise;
  }
  
  "Close the server. This will close any currently open connections. The returned promise will be resolved
    when the close is complete."
  shared Promise<Anything> close() {
    value handler = voidAsyncResult();
    delegate.close(handler);
    return handler.promise;
  }
}
