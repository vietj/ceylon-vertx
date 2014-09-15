import io.vertx.ceylon.platform {
  Verticle,
  Container
}
import io.vertx.ceylon {
  Vertx
}
shared class Sender() extends Verticle() {
  
  shared actual void doStart(Vertx vertx, Container container) {
    
    vertx.setPeriodic {
      delay = 1000;
      void handle(Integer timerId) {
        vertx.eventBus.publish("news-feed", "more news!");
      }
    };
  }
}