import io.vertx.ceylon { Registration, Vertx }
import ceylon.promise { Promise, Deferred }
import io.vertx.ceylon.eventbus { Message, EventBus, Payload }
import ceylon.test { ... }
import ceylon.json { JSonObject=Object, JSonArray=Array }
import test.io.vertx.ceylon{ assertResolve, toByteArray, with, eventBus  }
import java.lang { Character_=Character, String_=String, ByteArray, Short_=Short, Long_=Long, Integer_=Integer, Byte_=Byte, Float_=Float, Double_=Double, Boolean_=Boolean }
import org.vertx.java.core { Vertx_=Vertx }
import org.vertx.java.core.buffer { Buffer_=Buffer }
import org.vertx.java.core.eventbus { EventBus_=EventBus }
import io.vertx.ceylon.interop { VertxProvider_=VertxProvider }

shared test void testCharacterEvent() => with(eventBus(send('X')));
shared test void testByteEvent() => with(eventBus(send(123.byte)));
shared test void testFloatEvent() => with(eventBus(send(4.4)));
shared test void testIntegerEvent() => with(eventBus(send(4)));
shared test void testBooleanEvent() => with(eventBus(send(true)));
shared test void testStringEvent() => with(eventBus(send("foo_msg")));
shared test void testJSonObjectEvent() => with(eventBus(send(JSonObject({"juu"->"juu_value"}))));
shared test void testJSonArrayEvent() => with(eventBus(send(JSonArray({"juu","daa"}))));
shared test void testByteArray() => with(eventBus(send(toByteArray({0,1,2}))));
shared test void testBuffer() => with(eventBus(send(Buffer_("thebuffer"))));
shared test void testNull() => with(eventBus(send(null)));

shared test void testCharacterReply() => with(eventBus(reply('X')));
shared test void testByteReply() => with(eventBus(reply(123.byte)));
shared test void testFloatReply() => with(eventBus(reply(4.4)));
shared test void testIntegerReply() => with(eventBus(reply(4)));
shared test void testBooleanReply() => with(eventBus(reply(true)));
shared test void testStringReply() => with(eventBus(reply("foo_msg")));
shared test void testJSonObjectReply() => with(eventBus(reply(JSonObject({"juu"->"juu_value"}))));
shared test void testJSonArrayReply() => with(eventBus(reply(JSonArray({"juu","daa"}))));
shared test void testByteArrayReply() => with(eventBus(reply(toByteArray({0,1,2}))));
shared test void testBufferReply() => with(eventBus(reply(Buffer_("thebuffer"))));
shared test void testNullReply() => with(eventBus(reply(null)));

shared test void testCharacterReplyToReply() => with(eventBus(replyToReply('X')));
shared test void testByteReplyToReply() => with(eventBus(replyToReply(123.byte)));
shared test void testFloatReplyToReply() => with(eventBus(replyToReply(4.4)));
shared test void testIntegerReplyToReply() => with(eventBus(replyToReply(4)));
shared test void testBooleanReplyToReply() => with(eventBus(replyToReply(true)));
shared test void testStringReplyToReply() => with(eventBus(replyToReply("foo_msg")));
shared test void testJSonObjectReplyToReply() => with(eventBus(replyToReply(JSonObject({"juu"->"juu_value"}))));
shared test void testJSonArrayReplyToReply() => with(eventBus(replyToReply(JSonArray({"juu","daa"}))));
shared test void testByteArrayReplyToReply() => with(eventBus(replyToReply(toByteArray({0,1,2}))));
shared test void testBufferReplyToReply() => with(eventBus(replyToReply(Buffer_("thebuffer"))));
shared test void testNullReplyToReply() => with(eventBus(replyToReply(null)));

shared test void testJavaByte1() => testNativeJavaType<Byte>(123.byte, (EventBus_ bus) => bus.send("foo", Byte_(123.byte)) );
shared test void testJavaByte2() => testNativeJavaType<Integer>(123, (EventBus_ bus) => bus.send("foo", Byte_(123.byte)) );
shared test void testJavaShort() => testNativeJavaType<Integer>(1234, (EventBus_ bus) => bus.send("foo", Short_(1234)) );
shared test void testJavaInteger() => testNativeJavaType<Integer>(12345, (EventBus_ bus) => bus.send("foo", Integer_(12345)) );
shared test void testJavaLong() => testNativeJavaType<Integer>(123456, (EventBus_ bus) => bus.send("foo", Long_(123456)) );
shared test void testJavaFloat() => testNativeJavaType<Float>(3.140000104904175, (EventBus_ bus) => bus.send("foo", Float_(3.14)) );
shared test void testJavaDouble() => testNativeJavaType<Float>(3.14, (EventBus_ bus) => bus.send("foo", Double_(3.14)) );
shared test void testJavaBoolean() => testNativeJavaType<Boolean>(true, (EventBus_ bus) => bus.send("foo", Boolean_(true)) );
shared test void testJavaString() => testNativeJavaType<String>("foobar", (EventBus_ bus) => bus.send("foo", String_("foobar")) );
shared test void testJavaCharacter() => testNativeJavaType<Character>('X', (EventBus_ bus) => bus.send("foo", Character_('X')) );
shared test void testJavaBuffer() => testNativeJavaType<Buffer_>(Buffer_("thebuffer"), (EventBus_ bus) => bus.send("foo", Buffer_("thebuffer")) );

T? nullValue<T>() {
  return null;
}

shared test void testJavaNullByte() => testNativeJavaType<Byte?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Byte_>()) );
shared test void testJavaNullShort() => testNativeJavaType<Integer?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Short_>()) );
shared test void testJavaNullInteger() => testNativeJavaType<Integer?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Integer_>()) );
shared test void testJavaNullLong() => testNativeJavaType<Integer?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Long_>()) );
shared test void testJavaNullFloat() => testNativeJavaType<Float?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Float_>()) );
shared test void testJavaNullDouble() => testNativeJavaType<Float?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Double_>()) );
shared test void testJavaNullBoolean() => testNativeJavaType<Boolean?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Boolean_>()) );
shared test void testJavaNullString() => testNativeJavaType<String?>(null, (EventBus_ bus) => bus.send("foo", nullValue<String>()) );
shared test void testJavaNullCharacter() => testNativeJavaType<Character?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Character_>()) );
shared test void testJavaNullBuffer() => testNativeJavaType<Buffer_?>(null, (EventBus_ bus) => bus.send("foo", nullValue<Buffer_>()) );

shared test void testJavaIntegerOrString1() => testNativeJavaType<Integer|String>(3, (EventBus_ bus) => bus.send("foo", Long_(3)) );
shared test void testJavaIntegerOrString2() => testNativeJavaType<Integer|String>("3", (EventBus_ bus) => bus.send("foo", String_("3")) );

void testNativeJavaType<C>(C expected, void send(EventBus_ bus)) {
  Vertx_ native = VertxProvider_.create();
  value vertx = Vertx(native);
  value deferred = Deferred<C>();
  vertx.eventBus.registerHandler("foo", (Message<C> msg) => deferred.fulfill(msg.body));
  send(native.eventBus());
  value payload = assertResolve(deferred);	
  assertEquals(payload, expected);
}

void send<M>(M msg)(EventBus bus) {
    assert(is Payload msg);
    value deferred = Deferred<M>();
    Registration registration = bus.registerHandler("foo", (Message<M> msg) => deferred.fulfill(msg.body));
    assertResolve(registration.completed);
    bus.send("foo", msg);
    value payload = deferred.promise.future.get(1000);	
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

void reply<M>(M msg)(EventBus bus) {
    assert(is Payload msg);
    Registration registration = bus.registerHandler("foo", (Message<String> whateverMsg) => whateverMsg.reply(msg));
    assertResolve(registration.completed);
    value deferred = Deferred<M>();
    Promise<Message<M>> reply = bus.send<M>("foo", "whatever");
    reply.compose( (Message<M> msg) => deferred.fulfill(msg.body));
    value payload = deferred.promise.future.get(1000);	
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

void replyToReply<M>(M msg)(EventBus bus) given M of String|JSonObject|Boolean|Integer|Float|JSonArray|ByteArray|Byte|Character|Buffer_|Null {
    assert(is Payload msg);
    value deferred = Deferred<M>();
    Registration registration = bus.registerHandler("foo",
        (Message<String> whateverMsg) => whateverMsg.reply<M>("whatever_reply").
            compose((Message<M> whateverReplyMsg) => deferred.fulfill(whateverReplyMsg.body)));
    assertResolve(registration.completed);
    Promise<Message<String>> whateverReply = bus.send<String>("foo", "whatever");
    whateverReply.compose( (Message<String> whateverReplyMsg) => whateverReplyMsg.reply(msg));
    value payload = deferred.promise.future.get(1000);	
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
