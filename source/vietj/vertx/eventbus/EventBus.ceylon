/*
 * Copyright 2013 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import org.vertx.java.core.eventbus { EventBus_=EventBus, Message_=Message }
import org.vertx.java.core { Handler_=Handler }
import org.vertx.java.core.json { JsonObject_=JsonObject }
import vietj.promises { Promise }
import java.lang { String_=String, Void_=Void }
import vietj.vertx.interop { EventBusAdapter { registerHandler_=registerHandler, unregisterHandler_=unregisterHandler } }
import vietj.vertx { Registration }
import vietj.vertx.util { HandlerPromise, fromObject, toObject }
import ceylon.json { JSonObject=Object, JSonArray=Array }

// What a message body can be
//shared alias BodyType => String|JSonObject|JSonArray;

by "Julien Viet"
license "ASL2"
doc "A distributed lightweight event bus which can encompass multiple vert.x instances.
     The event bus implements publish / subscribe, point to point messaging and request-response messaging.
     
     Messages sent over the event bus are represented by instances of the [Message] class.
     
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
shared class EventBus(EventBus_ delegate) {


	class HandlerAdapter<M>(Anything(Message<M>) handler) satisfies
		Handler_<Message_<Object>> {
		shared actual void handle(Message_<Object> eventDelegate) {
			String? replyAddress = eventDelegate.replyAddress();
			Object body = eventDelegate.body();
			void doReply(String|JSonObject|JSonArray body) {
				switch(body)
					case (is String) { eventDelegate.reply(body); }
					case (is JSonObject) { eventDelegate.reply(fromObject(body)); }
					else { }
			}
			if (is String_ body) {
				if (is Anything(Message<String>) handler) {
					handler(Message<String>(body.string, replyAddress, doReply)); 
				}
			} else if (is JsonObject_ body) {
				if (is Anything(Message<JSonObject>) handler) {
					handler(Message<JSonObject>(toObject(body), replyAddress, doReply)); 
				}
			}
		}
	}

	class RegistrableHandlerAdapter<M>(String address, Anything(Message<M>) handler) extends
			HandlerAdapter<M>(handler) satisfies Registration {
	
		// todo : should return a promise
		shared actual Promise<Null> cancel() {
			value resultHandler = HandlerPromise<Null, Void_>((Void_ s) => null);
			unregisterHandler_(delegate, address, this, resultHandler);
			return resultHandler.promise;
		} 

		shared Promise<Registration> register() {
			Registration r = this;
			value resultHandler = HandlerPromise<Registration, Void_>((Void_ s) => r);
			registerHandler_(delegate, address, this, resultHandler);
			return resultHandler.promise;
		}
	}

	doc "Send a message"
	shared EventBus send<M>(
		doc "The address to send it to"
		String address,
		doc "The message"
		String|JSonObject|JSonArray message,
		doc "Reply handler will be called when any reply from the recipient is received"
		Anything(Message<M>)? replyHandler = null) {
		if (exists replyHandler) {
			HandlerAdapter<M> handlerAdapter = HandlerAdapter<M>(replyHandler);
			switch (message)
				case (is String) { delegate.send(address, message, handlerAdapter); }
				case (is JSonObject) { delegate.send(address, fromObject(message), handlerAdapter); }
				case (is JSonArray) { throw Exception(); }
		} else {
			switch (message)
				case (is String) { delegate.send(address, message); }
				case (is JSonObject) { delegate.send(address, fromObject(message)); }
				case (is JSonArray) { throw Exception(); }
		}
		return this;
	}
	
	doc "Publish a message"
	shared EventBus publish<M>(
		doc "The address to send it to"
		String address,
		doc "The message"
		String|JSonObject|JSonArray message,
		doc "Reply handler will be called when any reply from the recipient is received"
		Anything(Message<M>)? replyHandler = null) {
		switch (message)
			case (is String) { delegate.publish(address, message); }
			case (is JSonObject) { delegate.publish(address, fromObject(message)); }
			case (is JSonArray) { throw Exception(); }
		return this;
	}

	doc "Registers a handler against the specified address. The method returns a promise that is resolved when the
	     register has been propagated to all nodes of the event bus."
	shared Promise<Registration> registerHandler<M>(
		doc "The address to register it at"
		String address,
		doc "The handler"
		Anything(Message<M>) handler) given M satisfies Object {
		RegistrableHandlerAdapter<M> handlerAdapter = RegistrableHandlerAdapter<M>(address, handler);
		return handlerAdapter.register();
	}
}