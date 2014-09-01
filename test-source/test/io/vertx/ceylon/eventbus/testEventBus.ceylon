import io.vertx.ceylon { Registration }
import ceylon.promise { Promise, Deferred }
import io.vertx.ceylon.eventbus { Message, EventBus, Payload }
import ceylon.test { ... }
import ceylon.json { JSonObject=Object, JSonArray=Array }
import test.io.vertx.ceylon{ assertResolve, toByteArray, with, eventBus  }
import java.lang { ByteArray }

shared test void testFloatEvent() => with(eventBus(send(4.4)));
shared test void testIntegerEvent() => with(eventBus(send(4)));
shared test void testBooleanEvent() => with(eventBus(send(true)));
shared test void testStringEvent() => with(eventBus(send("foo_msg")));
shared test void testJSonObjectEvent() => with(eventBus(send(JSonObject({"juu"->"juu_value"}))));
shared test void testJSonArrayEvent() => with(eventBus(send(JSonArray({"juu","daa"}))));
shared test void testByteArray() => with(eventBus(send(toByteArray({0,1,2}))));

shared test void testFloatReply() => with(eventBus(reply(4.4)));
shared test void testIntegerReply() => with(eventBus(reply(4)));
shared test void testBooleanReply() => with(eventBus(reply(true)));
shared test void testStringReply() => with(eventBus(reply("foo_msg")));
shared test void testJSonObjectReply() => with(eventBus(reply(JSonObject({"juu"->"juu_value"}))));
shared test void testJSonArrayReply() => with(eventBus(reply(JSonArray({"juu","daa"}))));
shared test void testByteArrayReply() => with(eventBus(reply(toByteArray({0,1,2}))));

shared test void testFloatReplyToReply() => with(eventBus(replyToReply(4.4)));
shared test void testIntegerReplyToReply() => with(eventBus(replyToReply(4)));
shared test void testBooleanReplyToReply() => with(eventBus(replyToReply(true)));
shared test void testStringReplyToReply() => with(eventBus(replyToReply("foo_msg")));
shared test void testJSonObjectReplyToReply() => with(eventBus(replyToReply(JSonObject({"juu"->"juu_value"}))));
shared test void testJSonArrayReplyToReply() => with(eventBus(replyToReply(JSonArray({"juu","daa"}))));
shared test void testByteArrayReplyToReply() => with(eventBus(replyToReply(toByteArray({0,1,2}))));


void send<M>(M msg)(EventBus bus) given M of String|JSonObject|Boolean|Integer|Float|JSonArray|ByteArray {
    assert(is Payload msg);
    value deferred = Deferred<M>();
    Registration registration = bus.registerHandler("foo", (Message<M> msg) => deferred.fulfill(msg.body));
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
    reply.compose( (Message<M> msg) => deferred.fulfill(msg.body));
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
            compose((Message<M> whateverReplyMsg) => deferred.fulfill(whateverReplyMsg.body)));
    assertResolve(registration.completed);
    Promise<Message<String>> whateverReply = bus.send<String>("foo", "whatever");
    whateverReply.compose( (Message<String> whateverReplyMsg) => whateverReplyMsg.reply(msg));
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
