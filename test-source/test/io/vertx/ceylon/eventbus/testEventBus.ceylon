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
import io.vertx.ceylon.eventbus { Message, EventBus, Payload }
import ceylon.test { ... }
import ceylon.json { JSonObject=Object, JSonArray=Array }
import test.io.vertx.ceylon{ assertResolve }
import java.lang { ByteArray, arrays }

void run(Anything(EventBus) test) {
	Vertx vertx = Vertx();
	try {
		test(vertx.eventBus);
	} finally {
		vertx.stop();
	}
}

shared test void testFloatEvent() => run(send(4.4));
shared test void testIntegerEvent() => run(send(4));
shared test void testBooleanEvent() => run(send(true));
shared test void testStringEvent() => run(send("foo_msg"));
shared test void testJSonObjectEvent() => run(send(JSonObject({"juu"->"juu_value"})));
shared test void testJSonArrayEvent() => run(send(JSonArray({"juu","daa"})));
shared test void testByteArray() => run(send(arrays.toByteArray({0,1,2})));

shared test void testFloatReply() => run(reply(4.4));
shared test void testIntegerReply() => run(reply(4));
shared test void testBooleanReply() => run(reply(true));
shared test void testStringReply() => run(reply("foo_msg"));
shared test void testJSonObjectReply() => run(reply(JSonObject({"juu"->"juu_value"})));
shared test void testJSonArrayReply() => run(reply(JSonArray({"juu","daa"})));
shared test void testByteArrayReply() => run(reply(arrays.toByteArray({0,1,2})));

shared test void testFloatReplyToReply() => run(replyToReply(4.4));
shared test void testIntegerReplyToReply() => run(replyToReply(4));
shared test void testBooleanReplyToReply() => run(replyToReply(true));
shared test void testStringReplyToReply() => run(replyToReply("foo_msg"));
shared test void testJSonObjectReplyToReply() => run(replyToReply(JSonObject({"juu"->"juu_value"})));
shared test void testJSonArrayReplyToReply() => run(replyToReply(JSonArray({"juu","daa"})));
shared test void testByteArrayReplyToReply() => run(replyToReply(arrays.toByteArray({0,1,2})));


void send<M>(M msg)(EventBus bus) given M of String|JSonObject|Boolean|Integer|Float|JSonArray|ByteArray {
    assert(is Payload msg);
    value deferred = Deferred<M>();
    Registration registration = bus.registerHandler("foo", (Message<M> msg) => deferred.resolve(msg.body));
    assertResolve(registration.completed);
    bus.send("foo", msg);
    value payload = deferred.promise.future.get(1000);	
    assert(exists payload);
    if (is ByteArray msg) {
        assert(is ByteArray payload);
        // backend error : disabled for now
        // assertEquals(msg.array, payload.array);
    } else {
        assertEquals(msg, payload);
    }
    Promise<Null> cancel = registration.cancel();
    assertResolve(cancel);
}

void reply<M>(M msg)(EventBus bus) given M of String|JSonObject|Boolean|Integer|Float|JSonArray|ByteArray {
    assert(is Payload msg);
    Registration registration = bus.registerHandler("foo", (Message<String> whateverMsg) => whateverMsg.reply(msg));
    assertResolve(registration.completed);
    value deferred = Deferred<M>();
    Promise<Message<M>> reply = bus.send<M>("foo", "whatever");
    reply.then_( (Message<M> msg) => deferred.resolve(msg.body));
    value payload = deferred.promise.future.get(1000);	
    assert(exists payload);
    if (is ByteArray msg) {
        assert(is ByteArray payload);
        // backend error : disabled for now
        // assertEquals(msg.array, payload.array);
    } else {
        assertEquals(msg, payload);
    }
    Promise<Null> cancel = registration.cancel();
    assertResolve(cancel);
}

void replyToReply<M>(M msg)(EventBus bus) given M of String|JSonObject|Boolean|Integer|Float|JSonArray|ByteArray {
    assert(is Payload msg);
    value deferred = Deferred<M>();
    Registration registration = bus.registerHandler("foo",
        (Message<String> whateverMsg) => whateverMsg.reply<M>("whatever_reply").
            then_((Message<M> whateverReplyMsg) => deferred.resolve(whateverReplyMsg.body)));
    assertResolve(registration.completed);
    Promise<Message<String>> whateverReply = bus.send<String>("foo", "whatever");
    whateverReply.then_( (Message<String> whateverReplyMsg) => whateverReplyMsg.reply(msg));
    value payload = deferred.promise.future.get(1000);	
    assert(exists payload);
    if (is ByteArray msg) {
        assert(is ByteArray payload);
        // backend error : disabled for now
        // assertEquals(msg.array, payload.array);
    } else {
        assertEquals(msg, payload);
    }
    Promise<Null> cancel = registration.cancel();
    assertResolve(cancel);
}
