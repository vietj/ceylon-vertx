import vietj.vertx { Vertx, Registration }
import vietj.promises { Promise }
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
	value future = Future<String>();
	Promise<Registration> promise = bus.registerHandler("foo", (Message<String> msg) => future.set(msg.body));
	Registration registration = assertResolve(promise);
	bus.send("foo", "foo_value");
	value payload = future.get();	
	assertEquals("foo_value", payload);
	Promise<Null> cancel = registration.cancel();
	assertResolve(cancel);
}

void testJSonEvent(EventBus bus) {
	value future2 = Future<Object>();
	Promise<Registration> promise2 = bus.registerHandler("bar", (Message<Object> msg) => future2.set(msg.body));
	Registration registration = assertResolve(promise2);
	Object o = Object({"juu"->"juu_value"});
	bus.send("bar", o);
	value payload2 = future2.get();
	assertEquals(Object({"juu"->"juu_value"}), payload2);
	Promise<Null> cancel = registration.cancel();
	assertResolve(cancel);
}

void testReply(EventBus bus) {
	Promise<Registration> promise = bus.registerHandler("foo", (Message<String> msg) => msg.reply("foo_reply"));
	Registration registration = assertResolve(promise);
	value future = Future<String>();
	bus.send("foo", "foo_value", (Message<String> msg) => future.set(msg.body));
	value payload = future.get();	
    assertEquals("foo_reply", payload);
	Promise<Null> cancel = registration.cancel();
	assertResolve(cancel);
}


