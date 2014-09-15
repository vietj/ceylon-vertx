import io.vertx.ceylon { Vertx }
import org.vertx.java.platform { Verticle_=Verticle }

"""A verticle is the unit of execution in the Vert.x platform
   Vert.x code is packaged into Verticle's and then deployed and executed by the Vert.x platform.
   Verticles can be written in different languages.
"""
shared abstract class Verticle() extends Verticle_() {
    
    "The start implementation invokes the [[Verticle.doStart]] method with the wrapped [[vertx]] and [[container]]"
    shared actual void start() {
      doStart(Vertx(vertx), Container(container));
    }
    
    shared actual void stop() {
      doStop();
    }
    
    shared default void doStart(Vertx vertx, Container container) {
    }

    shared default void doStop() {
    }
}