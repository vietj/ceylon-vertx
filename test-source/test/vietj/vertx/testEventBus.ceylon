import vietj.vertx { Vertx, Registration }
import vietj.promises { Promise, Deferred }
import vietj.vertx.eventbus { Message, EventBus }
import ceylon.test { ... }
import ceylon.json { Object }

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


