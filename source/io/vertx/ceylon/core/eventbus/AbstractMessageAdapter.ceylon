import org.vertx.java.core {
  Handler_=Handler
}
import org.vertx.java.core.eventbus {
  Message_=Message
}
import io.vertx.ceylon.core.util {
  fromObject
}
import ceylon.promise {
  ExecutionContext
}

by ("Julien Viet")
abstract class AbstractMessageAdapter<M>(ExecutionContext context)
    satisfies Handler_<Message_<Object>> {
  
  shared actual void handle(Message_<Object> eventDelegate) {
    String? replyAddress = eventDelegate.replyAddress();
    Object? body = eventDelegate.body();
    value adapted = fromObject<M>(body);
    if (is M adapted) {
      dispatch(Message<M>(context, eventDelegate, adapted, replyAddress));
    } else {
      reject(body);
    }
  }
  
  shared formal void dispatch(Message<M> message);
  
  shared formal void reject(Object? body);
}
