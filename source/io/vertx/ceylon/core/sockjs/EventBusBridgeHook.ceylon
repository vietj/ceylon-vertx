import ceylon.json {
  JsonObject=Object
}
import ceylon.promise {
  Deferred
}


"""A hook that you can use to receive various events on the EventBusBridge."""
shared interface EventBusBridgeHook {
  
  """Called when a new socket is created
     You can override this method to do things like check the origin header of a socket before
     accepting it.
     
     Return true to accept the socket, false to reject it"""
  shared formal Boolean handleSocketCreated(
    "sock The socket"
    SockJSSocket sock);
  
  "The socket has been closed"
  shared formal void handleSocketClosed(
    "The socket"
    SockJSSocket sock);
  
  "Client is sending or publishing on the socket"
  shared formal Boolean handleSendOrPub(
    "The sock"
    SockJSSocket sock,
    "if true it's a send else it's a publish"
    Boolean send,
    "The message"
    JsonObject msg,
    "The address the message is being sent/published to"
    String address);
  
  "Called before client registers a handler
   
   Return true to let the registration occur, false otherwise"
  shared formal Boolean handlePreRegister(
    "The socket"
    SockJSSocket sock,
    "The address"
    String address);
  
  "Called after client registers a handler"
  shared formal void handlePostRegister(
    "The socket"
    SockJSSocket sock,
    "The address"
    String address);
  
  "Client is unregistering a handler"
  shared formal Boolean handleUnregister(
    "The socket"
    SockJSSocket sock,
    "The address"
    String address);
  
  """Called before authorisation - you can override authorisation here if you don't want the default
     
     Return true if you wish to override authorisation"""
  shared formal Boolean handleAuthorise(
    "The auth message"
    JsonObject message,
    "The session ID"
    String sessionID,
    "call this when authorisation is complete"
    Deferred<Boolean> handler);
}
