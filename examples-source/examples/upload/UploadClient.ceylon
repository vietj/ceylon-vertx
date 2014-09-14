import io.vertx.ceylon.platform {
  Verticle,
  Container
}
import io.vertx.ceylon {
  Vertx
}
import io.vertx.ceylon.http {
  HttpClientResponse
}
import io.vertx.ceylon.file {
  AsyncFile
}
shared class UploadClient() extends Verticle() {
  
  shared actual void start(Vertx vertx, Container container) {
    
    value client = vertx.createHttpClient {
      port = 8080;
      host = "localhost";
    };
    
    value req = client.put("/some-url");
    req.response.onComplete((HttpClientResponse resp) => print("File uploaded ``resp.statusCode``"));

    String filename = "upload/upload.txt";
    value size = vertx.fileSystem.propsSync(filename).size;

    req.headers {
      "Content-Length" -> "``size``"
    };
    
    // For a chunked upload you don't need to specify size, just do:
    // req.setChunked(true);
    
    vertx.fileSystem.open(filename).onComplete(
      void (AsyncFile file) {
        value pump = file.readStream.pump(req.stream);
        pump.start();
        file.readStream.endHandler(void () {
          file.close().onComplete(
            void (Null n) {
              req.end();
              print("Request sent");
            },
            void (Throwable err) =>  err.printStackTrace()
          );
        });
      },
      void (Throwable err) =>  err.printStackTrace()
    );
  }
}