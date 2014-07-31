import org.vertx.java.core.http { HttpClient_=HttpClient  }

"An HTTP client that maintains a pool of connections to a specific host, at a specific port. The client supports
 pipelining of requests.
 
 If an instance is instantiated from an event loop then the handlers of the instance will always be called on that
 same event loop. If an instance is instantiated from some other arbitrary Java thread (i.e. when running embedded)
 then and event loop will be assigned to the instance and used when any of its handlers are called.
 
 Instances of HttpClient are thread-safe."
by("Julien Viet")
shared class HttpClient(HttpClient_ delegate) {

    shared Integer maxPoolSize => delegate.maxPoolSize;

    assign maxPoolSize => delegate.setMaxPoolSize(maxPoolSize);

    "The port"
    shared Integer port => delegate.port;

    "Set the port that the client will attempt to connect to the server on
     to `port`. The default value is `80`"
    assign port => delegate.setPort(port);

    "The host"
    shared String host => delegate.host;

    "Set the host that the client will attempt to connect to the server on
     to `host`. The default value is `localhost`"
    assign host => delegate.setHost(host);

    "Is the client keep alive?"
    shared Boolean keepAlive => delegate.keepAlive;

    "If `keepAlive` is `true` then, after the request has ended the connection
     will be returned to the pool where it can be used by another request.
     In this manner, many HTTP requests can be pipe-lined over an HTTP connection.
     Keep alive connections will not be closed until the `close()` method is invoked.
     
     If `keepAlive` is `false` then a new connection will be created for each request
     and it won't ever go in the pool, the connection will closed after the response
     has been received. Even with no keep alive, the client will not allow more
     than `maxPoolSize` connections to be created at any one time."
    assign keepAlive => delegate.setKeepAlive(keepAlive);

    "true if this client will validate the remote server's certificate hostname
     against the requested host"
    shared Boolean verifyHost => delegate.verifyHost;

    "If `verifyHost` is `true`, then the client will try to validate the
     remote server's certificate hostname against the requested host.
     Should default to `true`. This method should only be used in SSL mode,
     i.e. after `ssl` has been set to `true`."
    assign verifyHost => delegate.setVerifyHost(verifyHost);

    "The connect timeout in milliseconds."
    shared Integer connectTimeout => delegate.connectTimeout;

    "Set the connect timeout in milliseconds."
    assign connectTimeout => delegate.setConnectTimeout(connectTimeout);

    "This method returns an [[HttpClientRequest]] instance which represents an
     HTTP request with the specified `uri`. The specific HTTP method
     (e.g. GET, POST, PUT etc) is specified using the parameter `method`.
     
     When an HTTP response is received from the server the promise `response`
     is resolved with the response."
    shared HttpClientRequest request(String method, String uri) {
        return HttpClientRequest(delegate, method, uri);
    }
    
    """This method returns an [[HttpClientRequest]] instance which represents an HTTP GET request with the specified `uri`."""
    shared HttpClientRequest get(String uri) => request("GET", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP POST request with the specified `uri`."""
    shared HttpClientRequest post(String uri) => request("POST", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP OPTIONS request with the specified `uri`."""
    shared HttpClientRequest options(String uri) => request("OPTIONS", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP HEAD request with the specified `uri`."""
    shared HttpClientRequest head(String uri) => request("HEAD", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP TRACE request with the specified `uri`."""
    shared HttpClientRequest trace(String uri) => request("TRACE", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP PUT request with the specified `uri`."""
    shared HttpClientRequest put(String uri) => request("PUT", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP DELETE request with the specified `uri`."""
    shared HttpClientRequest delete(String uri) => request("DELETE", uri);

    """This method returns an [[HttpClientRequest]] instance which represents an HTTP CONNECT request with the specified `uri`."""
    shared HttpClientRequest connect(String uri) => request("CONNECT", uri);
    
    """This method returns an [[HttpClientRequest]] instance which represents an HTTP PATCH request with the specified `uri`."""
    shared HttpClientRequest patch(String uri) => request("PATCH", uri);

    "Close the HTTP client. This will cause any pooled HTTP connections to be closed."
    shared void close() {
        delegate.close();
    }
    
}

