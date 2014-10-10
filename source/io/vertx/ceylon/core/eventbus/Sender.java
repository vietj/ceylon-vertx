package io.vertx.ceylon.core.eventbus;

import org.vertx.java.core.json.JsonArray;
import org.vertx.java.core.json.JsonObject;
import org.vertx.java.core.eventbus.EventBus;
import org.vertx.java.core.eventbus.Message;
import org.vertx.java.core.buffer.Buffer;
import org.vertx.java.core.Handler;

class Sender {
	
	static void send(EventBus bus, String address, Buffer body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Character body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Byte body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Float body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Integer body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Boolean body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Double body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, Long body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, String body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, byte[] body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, JsonArray body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}

	static void send(EventBus bus, String address, JsonObject body, Handler<Message<Object>> replyHandler) {
		bus.send(address, body, replyHandler);
	}
}
