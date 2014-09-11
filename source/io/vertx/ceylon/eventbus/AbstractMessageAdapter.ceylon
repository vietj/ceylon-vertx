import ceylon.json { JSonArray=Array, JSonObject=Object }
import org.vertx.java.core { Handler_=Handler }
import org.vertx.java.core.eventbus { Message_=Message }
import io.vertx.ceylon.util { fromObject }
import java.lang { ByteArray }
import org.vertx.java.core.buffer { Buffer_=Buffer }

by("Julien Viet")
abstract class AbstractMessageAdapter<M>() 
        satisfies Handler_<Message_<Object>>
        given M of String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray|Byte|Character|Buffer_|Null {
    
    shared actual void handle(Message_<Object> eventDelegate) {
        String? replyAddress = eventDelegate.replyAddress();
        Object? body = eventDelegate.body();
        value adapted = fromObject<M>(body);
        if (is M adapted) {
          dispatch(Message<M>(eventDelegate, adapted, replyAddress));
        } else {
          reject(body);
        }
    }
    
    shared formal void dispatch(Message<M> message);
    
    shared formal void reject(Object? body);
    
}