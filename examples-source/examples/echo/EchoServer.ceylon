import io.vertx.ceylon.platform {
  Verticle,
  Container
}
import io.vertx.ceylon {
  Vertx
}
import io.vertx.ceylon.net {
  NetSocket
}
import io.vertx.ceylon.stream {
  Pump
}
shared class EchoServer() extends Verticle() {
  
  shared actual void start(Vertx vertx, Container container) {
    vertx.createNetServer().connectHandler(void (NetSocket sock) {
      Pump(sock.readStream, sock.writeStream).start();
    }).listen(1234);
  }  
}