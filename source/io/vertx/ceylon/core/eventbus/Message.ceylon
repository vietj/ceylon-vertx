import ceylon.json {
  JSonArray=Array,
  JSonObject=Object
}
import org.vertx.java.core.eventbus {
  Message_=Message
}
import org.vertx.java.core.buffer {
  Buffer_=Buffer
}
import io.vertx.ceylon.core.util {
  toJsonObject,
  toJsonArray
}
import org.vertx.java.core {
  Handler_=Handler
}
import ceylon.promise {
  Promise
}
import java.lang {
  Byte_=Byte,
  Double_=Double,
  Long_=Long,
  Boolean_=Boolean,
  ByteArray,
  Character_=Character
}

"Represents a message on the event bus."
by ("Julien Viet")
shared class Message<T = Anything>(
  "The wrapped message"
  Message_<Object> delegate,
  "The body of the message"
  shared T body,
  "The body of the message"
  shared String? replyAddress) {
  
  "Reply to this message. If the message was sent specifying a reply handler, that handler will be
   called when it has received a reply. If the message wasn't sent specifying a receipt handler
   this method does nothing."
  shared Promise<Message<M>> reply<M = Nothing>(Payload? body = null) {
    
    //
    Handler_<Message_<Object>>? replyHandler;
    Promise<Message<M>> promise;
    if (`M` == `Nothing`) {
      replyHandler = null;
      promise = promiseOfNothing;
    } else {
      MessageAdapter<M> adapter = MessageAdapter<M>();
      replyHandler = adapter;
      promise = adapter.deferred.promise;
    }
    
    //
    switch (body)
    case (is Null) { delegate.reply(replyHandler); }
    case (is Buffer_) { delegate.reply(body, replyHandler); }
    case (is Character) { delegate.reply(Character_(body), replyHandler); }
    case (is Byte) { delegate.reply(Byte_(body), replyHandler); }
    case (is Float) { delegate.reply(Double_(body), replyHandler); }
    case (is Integer) { delegate.reply(Long_(body), replyHandler); }
    case (is Boolean) { delegate.reply(Boolean_(body), replyHandler); }
    case (is String) { delegate.reply(body, replyHandler); }
    case (is JSonObject) { delegate.reply(toJsonObject(body), replyHandler); }
    case (is JSonArray) { delegate.reply(toJsonArray(body), replyHandler); }
    case (is ByteArray) { delegate.reply(body, replyHandler); }
    
    //
    return promise;
  }
}
