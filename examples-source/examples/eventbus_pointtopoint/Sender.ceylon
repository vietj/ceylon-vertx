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
shared class Sender() extends Verticle() {
  
  shared actual void doStart(Vertx vertx, Container container) {
    
    vertx.setPeriodic {
      delay = 1000;
      void handle(Integer timerId) {
        vertx.eventBus.
            send<String>("ping-address", "ping!").
            onComplete((Message<String> msg) => print("Received reply: ``msg.body``"));
      }
    };
  }
}