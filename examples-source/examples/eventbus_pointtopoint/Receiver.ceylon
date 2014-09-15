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
  
  shared actual void doStart(Vertx vertx, Container container) {
    vertx.eventBus.registerHandler {
      address = "ping-address";
      void handler(Message<String> msg) {
        print("Received message: ``msg.body``");
        msg.reply("pong!");
      }
    }; 
  }  
}