import io.vertx.ceylon.platform { Platform, Deployment }
shared void run() {
  print("running");
  value plf = Platform();
  plf.deployVerticle("examples.echo.EchoServer").onComplete(
    (Deployment depl) => plf.deployVerticle("examples.echo.EchoClient"),
    (Throwable t) => t.printStackTrace()
  );  
  print("running2");
}