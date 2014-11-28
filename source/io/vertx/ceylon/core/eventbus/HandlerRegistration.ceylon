import io.vertx.ceylon.core.util {
  voidAsyncResult
}
import org.vertx.java.core {
  Handler_=Handler
}
import ceylon.promise {
  Promise,
  ExecutionContext
}
import io.vertx.ceylon.core {
  Registration
}
import org.vertx.java.core.eventbus {
  Message_=Message,
  EventBus_=EventBus
}

by ("Julien Viet")
class HandlerRegistration<M>(ExecutionContext context, EventBus_ delegate, String address, Anything(Message<M>) handler)
    extends AbstractMessageAdapter<M>(context)
    satisfies Registration & Handler_<Message_<Object>> {
  
  value resultHandler = voidAsyncResult(context);
  shared actual Promise<Anything> completed => resultHandler.promise;
  
  shared actual Promise<Anything> cancel() {
    value cancelled = voidAsyncResult(context);
    delegate.unregisterHandler(address, this, cancelled);
    return cancelled.promise;
  }
  
  shared void register() {
    delegate.registerHandler(address, this, resultHandler);
  }
  
  shared actual void dispatch(Message<M> message) {
    handler(message);
  }
  
  shared actual void reject(Object? body) {
    // ????
  }
}
