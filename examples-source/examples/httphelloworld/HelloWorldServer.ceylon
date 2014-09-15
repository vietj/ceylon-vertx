import io.vertx.ceylon.platform {
  Verticle,
  Container
}
import io.vertx.ceylon {
  Vertx
}
import io.vertx.ceylon.http {
  HttpServerRequest
}
shared class HelloWorldServer() extends Verticle() {
  
  shared actual void doStart(Vertx vertx, Container container) {
    vertx.createHttpServer().requestHandler(void (HttpServerRequest req) {
      req.response.headers { "Content-Type" -> "text/plain" };
      req.response.end("Hello World");
    }).listen(8080);
  }  
}