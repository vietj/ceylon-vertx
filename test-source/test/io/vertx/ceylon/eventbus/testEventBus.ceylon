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
import io.vertx.ceylon { Vertx, Registration }
import ceylon.promises { Promise, Deferred }
import io.vertx.ceylon.eventbus { Message, EventBus }
import ceylon.test { ... }
import ceylon.json { Object }
import test.io.vertx.ceylon{ assertResolve }

void run(Anything(EventBus) test) {
	Vertx vertx = Vertx();
	try {
		test(vertx.eventBus);
	} finally {
		vertx.stop();
	}
}

shared test void testStringEvent() => run(stringEvent);
shared test void testJSonEvent() => run(jsonEvent);
shared test void testReply() => run(reply);

void stringEvent(EventBus bus) {
    value deferred = Deferred<String>();
    Registration registration = bus.registerHandler("foo", (Message<String> msg) => deferred.resolve(msg.body));
    assertResolve(registration.completed);
    bus.send("foo", "foo_value");
    value payload = deferred.promise.future.get();	
    assertEquals("foo_value", payload);
    Promise<Null> cancel = registration.cancel();
    assertResolve(cancel);
}

void jsonEvent(EventBus bus) {
    value deferred = Deferred<Object>();
    Registration registration = bus.registerHandler("bar", (Message<Object> msg) => deferred.resolve(msg.body));
    assertResolve(registration.completed);
    Object o = Object({"juu"->"juu_value"});
    bus.send("bar", o);
    value payload2 = deferred.promise.future.get();
    assertEquals(Object({"juu"->"juu_value"}), payload2);
    Promise<Null> cancel = registration.cancel();
    assertResolve(cancel);
}

void reply(EventBus bus) {
    Registration registration = bus.registerHandler("foo", (Message<String> msg) => msg.reply("foo_reply"));
    assertResolve(registration.completed);
    value deferred = Deferred<String>();
    Promise<Message<String>> reply = bus.send<String>("foo", "foo_value");
    reply.then_( (Message<String> msg) => deferred.resolve(msg.body));
    value payload = deferred.promise.future.get();	
    assertEquals("foo_reply", payload);
    Promise<Null> cancel = registration.cancel();
    assertResolve(cancel);
}
