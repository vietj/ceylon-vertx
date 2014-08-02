import org.vertx.java.core.http { HttpServer_=HttpServer, HttpServerRequest_=HttpServerRequest }
import org.vertx.java.core { Handler_=Handler}
import ceylon.promise { Promise }
import java.lang { Void_=Void }
import io.vertx.ceylon.util { HandlerPromise }

"An HTTP and WebSockets server

 If an instance is instantiated from an event loop then the handlers of the instance will
 always be called on that same event loop. If an instance is instantiated from some other
 arbitrary Java thread then an event loop will be assigned to the instance and used when
 any of its handlers are called.
 
 Instances of HttpServer are thread-safe."
by("Julien Viet")
shared class HttpServer(HttpServer_ delegate) {
	
	"Set the request handler for the server to `requestHandler`. As HTTP requests are received by the server,
     instances of [[HttpServerRequest]] will be created and passed to this handler."
	shared HttpServer requestHandler(void handle(HttpServerRequest req)) {
		Anything(HttpServerRequest) handleRef = handle;
		object handler satisfies Handler_<HttpServerRequest_> {
			shared actual void handle(HttpServerRequest_ delegate) {
				handleRef(InternalHttpServerRequest(delegate));
			}
		}
		delegate.requestHandler(handler);
		return this;
	}

    "Tell the server to start listening on all available interfaces and port `port`.
     Be aware this is an async operation and the server may not bound on return of the method.
     The returned promise is resolved when the server is listening"
    shared Promise<HttpServer> listen(Integer port, String? hostName = null) {
        value server = this;
        value handler = HandlerPromise<HttpServer, HttpServer_>(
            (HttpServer_ s) => server);
        if (exists hostName) {
            delegate.listen(port, hostName, handler);
        } else {
            delegate.listen(port, handler);
        }
        return handler.promise;
    }

    "Close the server. Any open HTTP connections will be closed.
     The returned promise is resolved when the close is complete."	
    shared Promise<Null> close() {
        value handler = HandlerPromise<Null, Void_>((Void_ v) => null);
        delegate.close(handler);
        return handler.promise;
    }

}