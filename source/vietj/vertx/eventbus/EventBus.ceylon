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
import vietj.vertx.eventbus { EventBusAdapter { registerHandler_=registerHandler, unregisterHandler_=unregisterHandler } }
import vietj.vertx { HandlerPromise, fromObject, toObject, Registration }
import ceylon.json { JSonObject=Object, JSonArray=Array }

// What a message body can be
shared alias BodyType => String|JSonObject|JSonArray;

by "Julien Viet"
license "ASL2"
shared class EventBus(EventBus_ delegate) {


	class HandlerAdapter<M>(Anything(Message<M>) handler) satisfies
		Handler_<Message_<Object>> {
		shared actual void handle(Message_<Object> eventDelegate) {
			String? replyAddress = eventDelegate.replyAddress();
			Object body = eventDelegate.body();
			void doReply(BodyType body) {
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

	shared EventBus send<M>(String address, BodyType message, Anything(Message<M>)? replyHandler = null) {
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
	
	shared EventBus publish<M>(String address, BodyType message, Anything(Message<M>)? replyHandler = null) {
		switch (message)
			case (is String) { delegate.publish(address, message); }
			case (is JSonObject) { delegate.publish(address, fromObject(message)); }
			case (is JSonArray) { throw Exception(); }
		return this;
	}

	shared Promise<Registration> registerHandler<M>(String address, Anything(Message<M>) handler) given M satisfies Object {
		RegistrableHandlerAdapter<M> handlerAdapter = RegistrableHandlerAdapter<M>(address, handler);
		return handlerAdapter.register();
	}
}