import ceylon.test {
  ...
}
import io.vertx.ceylon.core {
  Vertx
}
import ceylon.promise {
  Deferred
}
import test.io.vertx.ceylon.core {
  with,
  assertResolve,
  testContext
}

shared test
void testTimer() => with {
  void test(Vertx vertx) {
    value deferred = Deferred<Integer>(testContext);
    value id1 = vertx.setTimer(100, deferred.fulfill);
    value id2 = assertResolve(deferred.promise, 300);
    assertEquals(id1, id2);
  }
};

shared test
void testPeriodicTimer() => with {
  void test(Vertx vertx) {
    value deferred = Deferred<Integer>(testContext);
    value a = Deferred<Null>(testContext);
    variable Integer count = 0;
    value id1 = vertx.setPeriodic(10, void(Integer timerId) {
        if (count == 10) {
          vertx.cancelTimer(timerId);
          deferred.fulfill(timerId);
        } else if (count > 10) {
          a.fulfill(null);
        }
        count++;
      });
    value id2 = assertResolve(deferred.promise, 300);
    assertEquals(id1, id2);
    assertThatException(() => assertResolve(a.promise, 50));
  }
};
