import ceylon.test { ... }
import io.vertx.ceylon { Vertx }
import ceylon.promises { Deferred }

void run(Anything(Vertx) test) {
    value vertx = Vertx();
    try {
        test(vertx);
    } finally {
        vertx.stop();
    }
}

shared test void testTimer() => run(timer);
shared test void testPeriodicTimer() => run(periodicTimer);

void timer(Vertx vertx) {
    value deferred = Deferred<Integer>();
    value id1 = vertx.setTimer(100, deferred.resolve);
    value id2 = deferred.promise.future.get(300);
    assertEquals(id1, id2);
}

void periodicTimer(Vertx vertx) {
    value deferred = Deferred<Integer>();
    value a = Deferred<Null>();
    variable Integer count = 0;
    value id1 = vertx.setPeriodic(10, void (Integer timerId) {
        if (count == 10) {
            vertx.cancelTimer(timerId);
            deferred.resolve(timerId);
        } else if (count > 10) {
            a.resolve(null);
        }
        count++;
    });
    value id2 = deferred.promise.future.get(300);
    assertEquals(id1, id2);
    assertThatException(() => a.promise.future.get(50));
}