import org.vertx.java.platform { Verticle_=Verticle }

shared class NativeVerticle() extends Verticle_() {
  
  shared actual void start() {
    print("starting verticle");
  }
}