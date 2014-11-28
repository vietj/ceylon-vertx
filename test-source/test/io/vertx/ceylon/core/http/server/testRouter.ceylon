import ceylon.test {
  test,
  assertEquals
}
import io.vertx.ceylon.core.http {
  HttpServer,
  HttpServerRequest,
  RouteMatcher
}
import test.io.vertx.ceylon.core {
  assertRequest,
  assertResolve,
  with,
  httpServer
}
import ceylon.collection {
  LinkedList,
  HashMap
}
import io.vertx.ceylon.core {
  Vertx
}

shared test
void testRouter() => with {
  httpServer {
    void test(Vertx vertx, HttpServer server) {
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
      value router = RouteMatcher(vertx);
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
  };
};

shared test
void testRouterParameters() => with {
  httpServer {
    void test(Vertx vertx, HttpServer server) {
      value router = RouteMatcher(vertx);
      value params = LinkedList<Map<String,{String+}>>();
      router.get {
        pattern = "/:blogname/:post";
        void handle(HttpServerRequest req) {
          params.add(req.params);
          req.response.status(200).end();
        }
      };
      assertResolve(server.requestHandler(router.handle).listen(8080));
      assertRequest("http://localhost:8080/blogname_value/post_value");
      assertEquals(LinkedList { HashMap { "post"->["post_value"], "blogname"->["blogname_value"] } }, params);
    }
  };
};
