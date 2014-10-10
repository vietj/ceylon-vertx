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
  with
}

shared test
void testTimer() => with {
  void test(Vertx vertx) {
    value deferred = Deferred<Integer>();
    value id1 = vertx.setTimer(100, deferred.fulfill);
    value id2 = deferred.promise.future.get(300);
    assertEquals(id1, id2);
  }
};

shared test
void testPeriodicTimer() => with {
  void test(Vertx vertx) {
    value deferred = Deferred<Integer>();
    value a = Deferred<Null>();
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
    value id2 = deferred.promise.future.get(300);
    assertEquals(id1, id2);
    assertThatException(() => a.promise.future.get(50));
  }
};
