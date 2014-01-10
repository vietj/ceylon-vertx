import ceylon.test { test, assertEquals }
import io.vertx.ceylon.http { HttpServer, HttpServerRequest, HttpServerResponse, RouteMatcher }
import ceylon.net.http { Header }
import ceylon.net.http.client { Response }
import test.io.vertx.ceylon { assertRequest, assertResolve }

shared test void testRouter() => run(router);

void router(HttpServer server) {
    variable Integer catsCount = 0;
    void cats(HttpServerRequest req) {
        catsCount++;
        req.response.status(200).end();
    }
    variable Integer dogsCount = 0;
    void dogs(HttpServerRequest req) {
        dogsCount++;
        req.response.status(200).end();
    }
    value router = RouteMatcher();
    router.get("/animal/cats", cats);
    router.get("/animal/dogs", dogs);
    assertResolve(server.requestHandler(router.handle).listen(8080));
    assertRequest("http://localhost:8080/animal/cats");
    assertEquals(1, catsCount);
    assertEquals(0, dogsCount);
    assertRequest("http://localhost:8080/animal/dogs");
    assertEquals(1, catsCount);
    assertEquals(1, dogsCount);
}
