import io.vertx.ceylon.platform {
  Verticle,
  Container
}
import io.vertx.ceylon {
  Vertx
}
import io.vertx.ceylon.eventbus {
  Message
}
shared class Receiver() extends Verticle() {
  
  shared actual void start(Vertx vertx, Container container) {
    vertx.eventBus.registerHandler {
      address = "news-feed";
      void handler(Message<String> msg) {
        print("Received news: ``msg.body``");
      }
    }; 
  }  
}