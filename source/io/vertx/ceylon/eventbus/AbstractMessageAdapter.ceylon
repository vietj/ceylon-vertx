import ceylon.json { JSonArray=Array, JSonObject=Object }
import org.vertx.java.core { Handler_=Handler }
import org.vertx.java.core.eventbus { Message_=Message }
import org.vertx.java.core.json { JsonObject_=JsonObject, JsonArray_=JsonArray }
import io.vertx.ceylon.util { toObject, toArray }
import java.lang { String_=String, Long_=Long, Boolean_=Boolean, Double_=Double, ByteArray }

by("Julien Viet")
abstract class AbstractMessageAdapter<M>() 
        satisfies Handler_<Message_<Object>>
        given M of String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray {
    
    shared actual void handle(Message_<Object> eventDelegate) {
        
        //
        String? replyAddress = eventDelegate.replyAddress();
        Object body = eventDelegate.body();
        
        M? abc;
        if (`M` == `String`) {
            if (is String_ body) {
                assert(is M c = body.string);
                abc = c;
            } else {
                abc = null;
            }
        } else if (`M` == `JSonObject`) {
            if (is JsonObject_ body) {
                assert(is M c = toObject(body));
                abc = c;
            } else {
                abc = null;
            }
        } else if (`M` == `JSonArray`) {
            if (is JsonArray_ body) {
                assert(is M c = toArray(body));
                abc = c;
            } else {
                abc = null;
            }
        } else if (`M` == `Float`) {
            if (is Double_ body) {
                assert(is M c = body.doubleValue());
                abc = c;
            } else {
                abc = null;
            }
        } else if (`M` == `Integer`) {
            if (is Long_ body) {
                assert(is M c = body.longValue());
                abc = c;
            } else {
                abc = null;
            }
        } else if (`M` == `Boolean`) {
            if (is Boolean_ body) {
                assert(is M c = body.booleanValue());
                abc = c;
            } else {
                abc = null;
            }
        } else if (`M` == `ByteArray`) {
            if (is ByteArray body) {
                assert(is M c = body);
                abc = c;
            } else {
                abc = null;
            }
        } else {
            // Not yet handled
            abc = null;
        }
        
        //
        if (exists a = abc) {
            dispatch(Message<M>(eventDelegate, a, replyAddress));
        } else {
            reject(body);
        }
    }
    
    shared formal void dispatch(Message<M> message);
    
    shared formal void reject(Object body);
    
}