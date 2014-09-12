import ceylon.test { ... }
import test.io.vertx.ceylon { with, assertResolveTo }
import io.vertx.ceylon { Vertx }
import io.vertx.ceylon.http { ServerWebSocket, WebSocket, WebSocketFrame, \iRFC6455 }
import ceylon.promise { Deferred }

shared test void clientSendHeader() => with {
  void test(Vertx vertx) {    
    value deferred = Deferred<String>(); 
    value server = vertx.createHttpServer();
    server.websocketHandler(void (ServerWebSocket websocket) {
      value header = websocket.headers["foo"];
      if (exists header) {
        deferred.fulfill(header[0]);
      } else {
        deferred.reject(Exception());
      }
    });
    server.listen(8080);
    value client = vertx.createHttpClient(8080);
    client.connectWebsocket {
      uri = "/foo";
      wsVersion = \iRFC6455;
      headers = { "foo"->"foo_value"  };
    };    
    assertResolveTo(deferred, "foo_value");
  }
};

shared test void clientSendMessage() => with {
  void test(Vertx vertx) {    
    value deferred = Deferred<String>(); 
    value server = vertx.createHttpServer();
    server.websocketHandler(void (ServerWebSocket websocket) {
      websocket.frameHandler(void (WebSocketFrame frame) {
        deferred.fulfill(frame.textData);
      });
    });
    server.listen(8080);
    value client = vertx.createHttpClient(8080);
    value ws = client.connectWebsocket("/foo");    
    ws.onComplete((WebSocket websocket) => websocket.writeTextFrame("helloFromClient"));
    assertResolveTo(deferred, "helloFromClient");
  }
};

shared test void serverSendMessage() => with {
  void test(Vertx vertx) {    
    value deferred = Deferred<String>(); 
    value server = vertx.createHttpServer();
    server.websocketHandler(void (ServerWebSocket websocket) {
      websocket.writeTextFrame("helloFromServer");
    });
    server.listen(8080);
    value client = vertx.createHttpClient(8080);
    value ws = client.connectWebsocket("/foo");    
    ws.onComplete((WebSocket websocket) => websocket.frameHandler(void (WebSocketFrame frame) {
        deferred.fulfill(frame.textData);
      })
    );
    assertResolveTo(deferred, "helloFromServer");
  }
};

shared test void clientCloseHandler() => with {
  void test(Vertx vertx) {    
    value server = vertx.createHttpServer();
    server.websocketHandler(void (ServerWebSocket websocket) {
      websocket.close();
    });
    server.listen(8080);
    value client = vertx.createHttpClient(8080);
    value deferred = Deferred<Null>(); 
    value ws = client.connectWebsocket("/foo");    
    ws.onComplete((WebSocket websocket) => websocket.closeHandler().compose(deferred.fulfill, deferred.reject));
    assertResolveTo(deferred, null);
  }
};

shared test void serverCloseHandler() => with {
  void test(Vertx vertx) {   
    value server = vertx.createHttpServer();
    value deferred = Deferred<Null>(); 
    server.websocketHandler(void (ServerWebSocket websocket) {
      websocket.closeHandler().compose(deferred.fulfill, deferred.reject);
    });
    server.listen(8080);
    value client = vertx.createHttpClient(8080);
    value ws = client.connectWebsocket("/foo");    
    ws.onComplete((WebSocket websocket) => websocket.close());
    assertResolveTo(deferred, null);
  }
};

shared test void serverRejects() => with {
  void test(Vertx vertx) {   
    value server = vertx.createHttpServer();
    server.websocketHandler(void (ServerWebSocket websocket) {
      websocket.reject();
    });
    server.listen(8080);
    value client = vertx.createHttpClient(8080);
    value deferred = Deferred<String>(); 
    client.exceptionHandler(void (Throwable t) {
      deferred.fulfill("rejected");
    });
    value ws = client.connectWebsocket("/foo");    
    ws.onComplete((WebSocket websocket) => deferred.reject(Exception()));
    assertResolveTo(deferred, "rejected");
  }
};
