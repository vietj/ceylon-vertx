import org.vertx.java.core { Vertx_=Vertx, Context_=Context }
import io.vertx.ceylon.core.http { HttpServer, HttpClient }
import io.vertx.ceylon.core.eventbus { EventBus }
import io.vertx.ceylon.core.shareddata { SharedData }
import java.lang { Long_=Long }
import io.vertx.ceylon.core.file { FileSystem }
import io.vertx.ceylon.core.sockjs { SockJSServer }
import io.vertx.ceylon.core.net { NetServer, NetClient }
import io.vertx.ceylon.core.util { NoArgVoidHandler }
import ceylon.promise { ExecutionContext }

"The control centre of the Vert.x Core API.
 
 You should normally only use a single instance of this class throughout your application. If you are running in the
 Vert.x container an instance will be provided to you.
 
 This class acts as a factory for TCP/SSL and HTTP/HTTPS servers and clients, SockJS servers, and provides an
 instance of the event bus, file system and shared data classes, as well as methods for setting and cancelling
 timers.
 
 Create a new Vertx instance. Instances of this class are thread-safe."
by ("Julien Viet")
shared class Vertx(shared Vertx_ delegate = VertxProvider.create()) {
  
  "The shared data object"
  shared SharedData sharedData = SharedData(delegate.sharedData());
  
  "The File system object"
  shared FileSystem fileSystem => FileSystem(this, delegate.fileSystem());
  
  "The event bus"
  shared EventBus eventBus => EventBus(this, delegate.eventBus());
  
  "Create a new net server and returns it"
  shared NetServer createNetServer() => NetServer(this, delegate.createNetServer());
  
  "Create a new http server and returns it"
  shared HttpServer createHttpServer() => HttpServer(this, delegate.createHttpServer());
  
  "Create a new http client and return it"
  shared HttpClient createHttpClient(
    "the client port"
    Integer? port = null,
    "the client host"
    String? host = null) {
    value client = delegate.createHttpClient();
    if (exists port) {
      client.setPort(port);
    }
    if (exists host) {
      client.setHost(host);
    }
    return HttpClient(this, client);
  }
  
  "Create a new net client and return it"
  shared NetClient createNetClient() => NetClient(this, delegate.createNetClient());
  
  "Put the handler on the event queue for the current loop (or worker context) so it will be run asynchronously
   ASAP after this event has
   been processed"
  shared void runOnContext(void task()) => delegate.runOnContext(NoArgVoidHandler(task));
  
  "The current context"
  shared Context? currentContext {
    Context_? ctx = delegate.currentContext();
    if (exists ctx) {
      return Context(ctx);
    } else {
      return null;
    }
  }
  
  "Is the current thread an event loop thread?"
  shared Boolean eventLoop => delegate.eventLoop;
  
  "Is the current thread an worker thread?"
  shared Boolean worker => delegate.worker;
  
  "Context for executing a promise on the vertx event loop"
  shared object executionContext satisfies ExecutionContext {
    shared actual void run(void task()) => delegate.runOnContext(NoArgVoidHandler(task));
    shared actual ExecutionContext childContext() => this;
  }
  
  "Stop the eventbus and any resource managed by the eventbus."
  shared void stop() {
    delegate.stop();
  }
  
  """Set a one-shot timer to fire after [[delay]] milliseconds, at which point [[handle]] will be called with
     the id of the timer.
     """
  shared Integer setTimer(Integer delay, void handle(Integer timerId)) {
    return delegate.setTimer(Long_(delay).longValue(), TimerProxy(handle));
  }
  
  """Set a periodic timer to fire every [[delay]] milliseconds, at which point [[handle]] will be called with
     the id of the timer.
     """
  shared Integer setPeriodic(Integer delay, void handle(Integer timerId)) {
    return delegate.setPeriodic(Long_(delay).longValue(), TimerProxy(handle));
  }
  
  """Cancel the timer with the specified [[id]]. Returns `true` true if the timer was successfully cancelled, or
     `false` if the timer does not exist."""
  shared Boolean cancelTimer(Integer id) {
    return delegate.cancelTimer(Long_(id).longValue());
  }
  
  "Create a SockJS server that wraps an HTTP server"
  shared SockJSServer createSockJSServer(HttpServer server) => server.createSockJSServer();
}
