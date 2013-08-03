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
import vietj.vertx { Vertx, Registration }
import vietj.promises { Promise, Deferred }
import vietj.vertx.eventbus { Message, EventBus }
import ceylon.test { ... }
import ceylon.json { Object }

by "Julien Viet"
license "ASL2"
void testEventBus() {
	for (test in {testStringEvent,testJSonEvent,testReply}) {
		Vertx vertx = Vertx();
		try {
			test(vertx.eventBus);
		} finally {
			vertx.stop();
		}
	}
}

void testStringEvent(EventBus bus) {
	value deferred = Deferred<String>();
	Promise<Registration> promise = bus.registerHandler("foo", (Message<String> msg) => deferred.resolve(msg.body));
	Registration registration = assertResolve(promise);
	bus.send("foo", "foo_value");
	value payload = deferred.promise.future.get();	
	assertEquals("foo_value", payload);
	Promise<Null> cancel = registration.cancel();
	assertResolve(cancel);
}

void testJSonEvent(EventBus bus) {
	value deferred = Deferred<Object>();
	Promise<Registration> promise2 = bus.registerHandler("bar", (Message<Object> msg) => deferred.resolve(msg.body));
	Registration registration = assertResolve(promise2);
	Object o = Object({"juu"->"juu_value"});
	bus.send("bar", o);
	value payload2 = deferred.promise.future.get();
	assertEquals(Object({"juu"->"juu_value"}), payload2);
	Promise<Null> cancel = registration.cancel();
	assertResolve(cancel);
}

void testReply(EventBus bus) {
	Promise<Registration> promise = bus.registerHandler("foo", (Message<String> msg) => msg.reply("foo_reply"));
	Registration registration = assertResolve(promise);
	value deferred = Deferred<String>();
	bus.send("foo", "foo_value", (Message<String> msg) => deferred.resolve(msg.body));
	value payload = deferred.promise.future.get();	
    assertEquals("foo_reply", payload);
	Promise<Null> cancel = registration.cancel();
	assertResolve(cancel);
}


