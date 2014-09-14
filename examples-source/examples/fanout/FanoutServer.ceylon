import io.vertx.ceylon.platform { Verticle, Container }
import io.vertx.ceylon { Vertx }
import io.vertx.ceylon.net { NetSocket }
import org.vertx.java.core.buffer { Buffer }

shared class FanoutServer() extends Verticle() {
  
  shared actual void start(Vertx vertx, Container container) {
    value connections = vertx.sharedData.getSet<String>("conns");
    vertx.createNetServer().connectHandler(void (NetSocket sock) {
      connections.add(sock.writeHandlerID);
      sock.readStream.dataHandler(void (Buffer buffer) {
        for (actorID in connections) {
          vertx.eventBus.publish(actorID, buffer);
        }
      });
      sock.closeHandler().onComplete((Null n) => connections.remove(sock.writeHandlerID));
    }).listen(1234);
  }
}