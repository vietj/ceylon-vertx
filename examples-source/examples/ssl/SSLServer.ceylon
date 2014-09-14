import io.vertx.ceylon.platform { Verticle, Container }
import io.vertx.ceylon { Vertx }
import io.vertx.ceylon.net { NetSocket }
shared class SSLServer() extends Verticle() {
  
  shared actual void start(Vertx vertx, Container container) {
    value server = vertx.createNetServer().connectHandler(void (NetSocket sock) {
      sock.readStream.dataHandler(sock.write);
    });
    server.ssl = true;
    server.keyStorePath = "server-keystore.jks";
    server.keyStorePassword = "wibble";
    server.listen(1234);
  }
  
}