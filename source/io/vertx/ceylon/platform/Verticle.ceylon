import io.vertx.ceylon { Vertx }
"""A verticle is the unit of execution in the Vert.x platform
   Vert.x code is packaged into Verticle's and then deployed and executed by the Vert.x platform.
   Verticles can be written in different languages.
"""
shared abstract class Verticle(shared Vertx vertx, shared Container container) {
    
    shared default void start() {
    }

    shared default void stop() {
    }
}