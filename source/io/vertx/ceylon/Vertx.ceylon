import org.vertx.java.core { Vertx_=Vertx, Handler_=Handler }
import io.vertx.ceylon.http { HttpServer, HttpClient }
import io.vertx.ceylon.eventbus { EventBus }
import io.vertx.ceylon.shareddata { SharedData }
import java.lang { Long_=Long, Void_=Void }
import io.vertx.ceylon.file {
  FileSystem
}
import io.vertx.ceylon.sockjs {
  SockJSServer
}

"The control centre of the Vert.x Core API.
 
 You should normally only use a single instance of this class throughout your application. If you are running in the
 Vert.x container an instance will be provided to you.
 
 This class acts as a factory for TCP/SSL and HTTP/HTTPS servers and clients, SockJS servers, and provides an
 instance of the event bus, file system and shared data classes, as well as methods for setting and cancelling
 timers.
 
 Create a new Vertx instance. Instances of this class are thread-safe."
by("Julien Viet")
shared class Vertx(Vertx_ v = VertxProvider.create()) {

    "The event bus"
    shared EventBus eventBus = EventBus(v.eventBus());

    "The shared data object"
    shared SharedData sharedData = SharedData(v.sharedData());
    
    "The File system object"
    shared FileSystem fileSystem = FileSystem(v.fileSystem());
    
    "Create a new http server and returns it"
    shared HttpServer createHttpServer() {
        return HttpServer(v, v.createHttpServer());
    }

    "Create a new http client and return it"
    shared HttpClient createHttpClient(
        "the client port"
        Integer? port = null,
        "the client host"
        String? host = null) {
        value client = v.createHttpClient();
        if (exists port) {
            client.setPort(port);
        }
        if (exists host) {
            client.setHost(host);
        }
        return HttpClient(client);
    }
    
    """Set a one-shot timer to fire after [[delay]] milliseconds, at which point [[handle]] will be called with
       the id of the timer.
       """
    shared Integer setTimer(Integer delay, void handle(Integer timerId)) {
        return v.setTimer(Long_(delay).longValue(), TimerProxy(handle));
    }
    
    """Set a periodic timer to fire every [[delay]] milliseconds, at which point [[handle]] will be called with
       the id of the timer.
       """
    shared Integer setPeriodic(Integer delay, void handle(Integer timerId)) {
        return v.setPeriodic(Long_(delay).longValue(), TimerProxy(handle));
    }
    
    "Put the handler on the event queue for the current loop (or worker context) so it will be run asynchronously
     ASAP after this event has
     been processed"
    shared void runOnContext(void task()) {
      object adapter satisfies Handler_<Void_> {
        shared actual void handle(Void_? e) {
          task();
        }
      }
      v.runOnContext(adapter);
    }

    """Cancel the timer with the specified [[id]]. Returns `true` true if the timer was successfully cancelled, or
       `false` if the timer does not exist."""
    shared Boolean cancelTimer(Integer id) {
        return v.cancelTimer(Long_(id).longValue());
    }
    
    "Stop Vertx"
    shared void stop() {
        v.stop();
    }
    
    "Create a SockJS server that wraps an HTTP server"
    shared SockJSServer createSockJSServer(HttpServer server) => server.createSockJSServer();

}