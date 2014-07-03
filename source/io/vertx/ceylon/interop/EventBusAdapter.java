package io.vertx.ceylon.interop;

import org.vertx.java.core.eventbus.EventBus;
import org.vertx.java.core.eventbus.Message;
import org.vertx.java.core.Handler;
import org.vertx.java.core.AsyncResult;

/**
 * Provide a facade for dealing with some operations of the EventBus that cannot be used
 * at the moment from Ceylon due to incomplete generic design.
 * 
 * @author julien
 */
public class EventBusAdapter {
  
  public static <T, M extends Message<T>> void registerHandler(
      EventBus eventBus, 
      String address, 
      Handler<M> handler,
      Handler<AsyncResult<Void>> resultHandler) {
    eventBus.registerHandler(address, handler, resultHandler);
  }

  public static <T, M extends Message<T>> void unregisterHandler(
      EventBus eventBus, 
      String address, 
      Handler<M> handler,
      Handler<AsyncResult<Void>> resultHandler) {
    eventBus.registerHandler(address, handler, resultHandler);
  }
}
