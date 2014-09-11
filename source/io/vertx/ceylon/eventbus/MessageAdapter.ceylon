import ceylon.json { JSonObject=Object, JSonArray=Array }
import ceylon.promise { Deferred }
import java.lang { ByteArray }
import org.vertx.java.core.buffer { Buffer_=Buffer }

by("Julien Viet")
class MessageAdapter<M>() extends AbstractMessageAdapter<M>() given M of String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray|Byte|Character|Buffer_|Null {
    
    "The deferred for the reply"
    shared Deferred<Message<M>> deferred = Deferred<Message<M>>();

    shared actual void dispatch(Message<M> message) {
        deferred.fulfill(message);
    }
     
    shared actual void reject(Object? body) {
       if (exists body) {
         deferred.reject(Exception("Wrong promise type for reply ``body``"));
       } else {
         deferred.reject(Exception("Wrong promise type for null reply"));
       }
    }
     
}
