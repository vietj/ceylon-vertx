import org.vertx.java.core.http { HttpServer_=HttpServer }
import org.vertx.java.core { Vertx_=Vertx }
import ceylon.promise { Promise }
import io.vertx.ceylon.util { AsyncResultPromise, FunctionalHandlerAdapter, voidAsyncResult }
import ceylon.collection { LinkedList }
import io.vertx.ceylon.sockjs { SockJSServer }

"An HTTP and WebSockets server

 If an instance is instantiated from an event loop then the handlers of the instance will
 always be called on that same event loop. If an instance is instantiated from some other
 arbitrary Java thread then an event loop will be assigned to the instance and used when
 any of its handlers are called.
 
 Instances of HttpServer are thread-safe."
by("Julien Viet")
shared class HttpServer(Vertx_ vertx, HttpServer_ delegate) {
	
	"Set the request handler for the server to `requestHandler`. As HTTP requests are received by the server,
     instances of [[HttpServerRequest]] will be created and passed to this handler."
	shared HttpServer requestHandler(void handle(HttpServerRequest req)) {
		delegate.requestHandler(FunctionalHandlerAdapter(InternalHttpServerRequest, handle));
		return this;
	}
	
	"""Set the websocket handler for the server to [[handle]]. If a websocket connect handshake is successful a
    new [[ServerWebSocket]] instance will be created and passed to the handle."""
	shared HttpServer websocketHandler(void handle(ServerWebSocket websocket)) {
		delegate.websocketHandler(FunctionalHandlerAdapter(ServerWebSocket, handle));
		return this;
	}
	
	"""Returns true if the [[HttpServer]] should compress the http response if the connected client supports it."""
	shared Boolean compressionSupported => delegate.compressionSupported;
	
	"""Set if the [[HttpServer]] should compress the http response if the connected client supports it."""
	assign compressionSupported => delegate.setCompressionSupported(compressionSupported);

  """The maximum websocket frame size in bytes."""
	shared Integer maxWebSocketFrameSize => delegate.maxWebSocketFrameSize;
	
	"""Sets the maximum websocket frame size in bytes. Default is 65536 bytes."""
	assign maxWebSocketFrameSize => delegate.setMaxWebSocketFrameSize(maxWebSocketFrameSize);

  """Returns all the supported subprotocols. An empty sequence is returned if
     non are supported. This is the default."""
	shared String[] webSocketSubProtocols {
		value list = LinkedList<String>();
		value iterator = delegate.webSocketSubProtocols.iterator();
		while (iterator.hasNext()) {
			list.add(iterator.next().string);
		}
		return [*list];
	}
	
	"""Set the supported websocket subprotocols. Using empty to disable support of subprotocols."""
	assign webSocketSubProtocols {
		if (webSocketSubProtocols.empty) {
			delegate.setWebSocketSubProtocols(null);
		} else {
			delegate.setWebSocketSubProtocols(*webSocketSubProtocols);
		}
	}
	
	shared SockJSServer createSockJSServer() {
		return SockJSServer(vertx.createSockJSServer(delegate));
	}
	

    "Tell the server to start listening on all available interfaces and port `port`.
     Be aware this is an async operation and the server may not bound on return of the method.
     The returned promise is resolved when the server is listening"
    shared Promise<HttpServer> listen(Integer port, String? hostName = null) {
        value server = this;
        value handler = AsyncResultPromise((HttpServer_ s) => server);
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
        value handler = voidAsyncResult();
        delegate.close(handler);
        return handler.promise;
    }
}