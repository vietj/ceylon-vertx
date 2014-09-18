import ceylon.test { ... }
import test.io.vertx.ceylon.core { ... }
import io.vertx.ceylon.core.net { NetSocket }
import io.vertx.ceylon.core { Vertx }
import org.vertx.java.core.buffer { Buffer }
import ceylon.promise { Deferred }

shared test void testClientServer() => with {
  void test(Vertx vertx) {
    value server = vertx.createNetServer();
    server.connectHandler(void (NetSocket sock) {
      sock.write("hello");
      sock.close();
    });
    assertResolve(server.listen(12345));
    value client = vertx.createNetClient();
    value socket = assertResolve(client.connect(12345));
    value acc = Buffer();
    value done = Deferred<Null>();
    socket.readStream.dataHandler(void (Buffer buffer) {
      acc.appendBuffer(buffer);
      if (acc.length() == 5) {
        done.fulfill(null);
      }
    });
    assertResolve(done);
    assertEquals(acc.toString("UTF-8"), "hello");
  }
};
