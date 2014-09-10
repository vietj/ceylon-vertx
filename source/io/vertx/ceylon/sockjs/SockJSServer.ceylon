import ceylon.json { JsonObject=Object, JsonArray=Array }
import org.vertx.java.core.json { JsonObject_=JsonObject }
import org.vertx.java.core.sockjs { SockJSServer_=SockJSServer, EventBusBridgeHook_=EventBusBridgeHook, SockJSSocket_=SockJSSocket }
import io.vertx.ceylon.util { FunctionalHandlerAdapter, fromObject, fromArray, toObject }
import org.vertx.java.core { Handler_=Handler, AsyncResult_=AsyncResult }
import org.vertx.java.core.impl { DefaultFutureResult_=DefaultFutureResult }
import java.lang { Boolean_=Boolean }
import ceylon.promise { Deferred }

"""This is an implementation of the server side part of [SockJS](https://github.com/sockjs)
   
   SockJS enables browsers to communicate with the server using a simple WebSocket-like api for sending
   and receiving messages. Under the bonnet SockJS chooses to use one of several protocols depending on browser
   capabilities and what appears to be working across the network.
   
   Available protocols include:
   
   - _WebSockets_
   - _xhr-polling_
   - _xhr-streaming_
   - _json-polling_
   - _event-source_
   - _html-file_
   
   This means, it should _just work_ irrespective of what browser is being used, and whether there are nasty
   things like proxies and load balancers between the client and the server.
   
   For more detailed information on SockJS, see their website.
   
   On the server side, you interact using instances of {@link SockJSSocket} - this allows you to send data to the
   client or receive data via the [[SockJSSocket.readStream]] [[io.vertx.ceylon.stream::ReadStream.dataHandler]].
   
   You can register multiple applications with the same SockJSServer, each using different path prefixes, each
   application will have its own handler, and configuration.
   
   Instances of this class are not thread-safe."""
shared class SockJSServer(SockJSServer_ delegate) {
  
  "Install an application"
  shared SockJSServer installApp(
    "The config for the app"
    JsonObject config,
    "A handler that will be called when new SockJS sockets are created"
    void sockHandler(SockJSSocket socket)) {
    delegate.installApp(fromObject(config), FunctionalHandlerAdapter(SockJSSocket, sockHandler));
    return this;
  }
  
  "Install an app which bridges the SockJS server to the event bus"
  shared SockJSServer bridge(
    "The config for the app"
    JsonObject sjsConfig,
    "A list of JSON objects which define permitted matches for inbound (client->server) traffic"
    JsonArray inboundPermitted,
    "A list of JSON objects which define permitted matches for outbound (server->client) traffic"
    JsonArray outboundPermitted,
    "JSON object holding config for the EventBusBridge"
    JsonObject? bridgeConfig = null) {
    if (exists bridgeConfig) {
      delegate.bridge(fromObject(sjsConfig), fromArray(inboundPermitted), fromArray(outboundPermitted), fromObject(bridgeConfig));
    } else {
      delegate.bridge(fromObject(sjsConfig), fromArray(inboundPermitted), fromArray(outboundPermitted));
    }
    return this;
  }
  
  "Set a EventBusBridgeHook on the SockJS server"
  shared SockJSServer setHook("The hook" EventBusBridgeHook hook) {
    
    object impl satisfies EventBusBridgeHook_ {
      
      shared actual Boolean handleAuthorise(JsonObject_ jsonObject, String sessionID, Handler_<AsyncResult_<Boolean_>> handler) {
        Deferred<Boolean> deferred = Deferred<Boolean>();
        deferred.promise.onComplete {
          void onFulfilled(Boolean b) {
            handler.handle(DefaultFutureResult_<Boolean_>(b then Boolean_.\iTRUE else Boolean_.\iFALSE));
          }
          void onRejected(Throwable t) {
            handler.handle(DefaultFutureResult_<Boolean_>(t));
          }
        };
        return hook.handleAuthorise(toObject(jsonObject), sessionID, deferred);
      }
      
      shared actual void handlePostRegister(SockJSSocket_ sockJSSocket, String address) {
        hook.handlePostRegister(SockJSSocket(sockJSSocket), address);
      }
      
      shared actual Boolean handlePreRegister(SockJSSocket_ sockJSSocket, String address) {
        return hook.handlePreRegister(SockJSSocket(sockJSSocket), address);
      }
      
      shared actual Boolean handleSendOrPub(SockJSSocket_ sockJSSocket, Boolean send, JsonObject_ msg, String address) {
        return hook.handleSendOrPub(SockJSSocket(sockJSSocket), send, toObject(msg), address);
      }
      
      shared actual void handleSocketClosed(SockJSSocket_ sockJSSocket) {
        hook.handleSocketClosed(SockJSSocket(sockJSSocket));
      }
      
      shared actual Boolean handleSocketCreated(SockJSSocket_ sockJSSocket) {
        return hook.handleSocketCreated(SockJSSocket(sockJSSocket));
      }
      
      shared actual Boolean handleUnregister(SockJSSocket_ sockJSSocket, String address) {
        return hook.handleUnregister(SockJSSocket(sockJSSocket), address);
      }
    }
    
    delegate.setHook(impl);
    
    return this;
  }
  
  "Close the server"
  shared void close() {
    delegate.close();
  }
}