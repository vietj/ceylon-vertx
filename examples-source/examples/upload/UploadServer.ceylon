import io.vertx.ceylon.platform { Verticle, Container }
import io.vertx.ceylon { Vertx }
import io.vertx.ceylon.http { HttpServerRequest }
import java.util { UUID }
import java.lang { System { currentTimeMillis } }
import io.vertx.ceylon.file { AsyncFile }

shared class UploadServer() extends Verticle() {
  
  shared actual void doStart(Vertx vertx, Container container) {
    
    vertx.createHttpServer().requestHandler(void (HttpServerRequest req) {
      
      // We first pause the request so we don't receive any data between now and when the file is opened
      value stream = req.stream;
      stream.pause();
      
      value filename = "upload/file-``UUID.randomUUID()``.upload";
      vertx.fileSystem.open(filename).onComplete(void (AsyncFile file) {
        value pump = stream.pump(file.writeStream);
        value start = currentTimeMillis();
        req.stream.endHandler(void () {
          file.close().onComplete(void (Null n) {
            req.response.end();
            value end = currentTimeMillis();
            print("Uploaded ``pump.bytesPumped`` bytes to ``pump.bytesPumped`` in ``(end - start)`` ms");
          }, (Throwable t) => t.printStackTrace());
        });
        pump.start();
        stream.resume();
      }, (Throwable t) => t.printStackTrace());
    }).listen(8080);
  }
}