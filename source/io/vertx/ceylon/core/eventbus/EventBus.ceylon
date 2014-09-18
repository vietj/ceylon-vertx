import org.vertx.java.core.eventbus { EventBus_=EventBus, Message_=Message }
import org.vertx.java.core.buffer { Buffer_=Buffer }
import ceylon.promise { Promise }
import io.vertx.ceylon.core { Registration }
import io.vertx.ceylon.core.util { toJsonObject, toJsonArray }
import ceylon.json { JSonObject=Object, JSonArray=Array }
import org.vertx.java.core { Handler_=Handler }
import java.lang { Character_=Character, Double_=Double, Long_=Long, Boolean_=Boolean, ByteArray, Byte_=Byte }

"A distributed lightweight event bus which can encompass multiple vert.x instances.
 The event bus implements publish / subscribe, point to point messaging and request-response messaging.
 
 Messages sent over the event bus are represented by instances of the [[Message]] class.
 
 For publish / subscribe, messages can be published to an address using one of the `publish` methods. An
 address is a simple `String` instance.
 
 Handlers are registered against an address. There can be multiple handlers registered against each address, and a particular handler can
 be registered against multiple addresses. The event bus will route a sent message to all handlers which are
 registered against that address.
 
 For point to point messaging, messages can be sent to an address using one of the `send` methods.
 The messages will be delivered to a single handler, if one is registered on that address. If more than one
 handler is registered on the same address, Vert.x will choose one and deliver the message to that. Vert.x will
 aim to fairly distribute messages in a round-robin way, but does not guarantee strict round-robin under all
 circumstances.
 
 All messages sent over the bus are transient. On event of failure of all or part of the event bus messages
 may be lost. Applications should be coded to cope with lost messages, e.g. by resending them, and making application
 services idempotent.
 
 The order of messages received by any specific handler from a specific sender should match the order of messages
 sent from that sender.
 
 When sending a message, a reply handler can be provided. If so, it will be called when the reply from the receiver
 has been received. Reply messages can also be replied to, etc, ad infinitum
 
 Different event bus instances can be clustered together over a network, to give a single logical event bus.<p>
 Instances of EventBus are thread-safe.
 
 If handlers are registered from an event loop, they will be executed using that same event loop. If they are
 registered from outside an event loop (i.e. when using Vert.x embedded) then Vert.x will assign an event loop
 to the handler and use it to deliver messages to that handler."
by("Julien Viet")
shared class EventBus(EventBus_ delegate) {
	
	"Send a message via the event bus. The returned promise allows to receive any reply message from the recipient."
	shared Promise<Message<M>> send<M = Nothing>(
    		"The address to send it to"
    		String address,
    		"The message"
    		Payload message) {

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
        switch (message)
        case (is Buffer_) { delegate.send(address, message, replyHandler); }
        case (is Character) { delegate.send(address, Character_(message), replyHandler); }
        case (is Byte) { delegate.send(address, Byte_(message), replyHandler); }
        case (is Float) { delegate.send(address, Double_(message), replyHandler); }
        case (is Integer) { delegate.send(address, Long_(message), replyHandler); }
        case (is Boolean) { delegate.send(address, Boolean_(message), replyHandler); }
        case (is String) { delegate.send(address, message, replyHandler); }
        case (is JSonObject) { delegate.send(address, toJsonObject(message), replyHandler); }
        case (is JSonArray) { delegate.send(address, toJsonArray(message), replyHandler); }
        case (is ByteArray) { delegate.send(address, message, replyHandler); }
        case (is Null) {
          String? dummy = null;
          delegate.send(address, dummy, replyHandler);
        }
        
        //
        return promise;
	}
	
	"Publish a message"
	shared void publish(
    		"The address to send it to"
    		String address,
    		"The message"
    		Payload message) {

		switch (message)
		case (is Buffer_) { delegate.publish(address, message); }
		case (is Character) { delegate.publish(address, message); }
		case (is Boolean) { delegate.publish(address, message); }
		case (is Byte) { delegate.publish(address, message); }
		case (is Float) { delegate.publish(address, message); }
		case (is Integer) { delegate.publish(address, message); }
		case (is String) { delegate.publish(address, message); }
		case (is JSonObject) { delegate.publish(address, toJsonObject(message)); }
		case (is JSonArray) { delegate.publish(address, toJsonArray(message)); }
		case (is ByteArray) { delegate.publish(address, message); }
		case (is Null) {
			String? dummy = null;
			delegate.publish(address, dummy);
		}
	}

    "Registers a handler against the specified address. The method returns a registration whose:
     * the `completed` promise is resolved when the register has been propagated to all nodes of the event bus
     * the `cancel()` method can be called to cancel the registration"
    shared Registration registerHandler<M>(
            "The address to register it at"
            String address,
            "The handler"
            Anything(Message<M>) handler) {
        HandlerRegistration<M> handlerAdapter = HandlerRegistration<M>(delegate, address, handler);
        handlerAdapter.register();
        return handlerAdapter;
    }
}