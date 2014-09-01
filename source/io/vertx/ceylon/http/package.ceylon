"""# Writing HTTP Servers and Clients
   
   ## Writing HTTP servers
   
   Vert.x allows you to easily write full featured, highly performant and scalable HTTP servers.
   
   ### Creating an HTTP Server
   
   To create an HTTP server you call the `createHttpServer` method on your `vertx` instance.
   
   ~~~
   HttpServer server = vertx.createHttpServer();
   ~~~
   
   ### Start the Server Listening
   
   To tell that server to listen for incoming requests you use the listen method:
   
   ~~~
   HttpServer server = vertx.createHttpServer();
   server.listen(8080, "myhost");
   ~~~
   
   The first parameter to listen is the `port`, The second parameter is the hostname or ip address. If it is omitted it will
   default to 0.0.0.0 which means it will listen at all available interfaces. Note that you could also do it this way:
   
   ~~~
   server.listen { port = 8080; hostName = "myhost"; };
   ~~~
   
   The actual bind is asynchronous so the server might not actually be listening until some time after the call to
   listen has returned. If you want to be notified when the server is actually listening you can use
   the `Promise<HttpServer>` returned by the `listen` method. For example:

   ~~~
   server.listen(8080, "myhost").
      onComplete(
        (HttpServer server) => print("Listen succeeded"),
        (Exception e) => print("Listen failed")
      );
   ~~~
   
   ### Getting Notified of Incoming Requests
   
   To be notified when a request arrives you need to set a request handler. This is done by calling the
   requestHandler method of the server, passing in the handler:
   
   ~~~
   value server = vertx.createHttpServer();
   
   void handle(HttpServerRequest request) {
     print(""A request has arrived on the server!");
     request.response.end();
   }
   
   server.requestHandler(handle);
   server.listen(8080, "localhost");
   ~~~
   
   ### Handling HTTP Requests
   
   So far we have seen how to create an `HttpServer` and be notified of requests. Lets take a look at how to handle
   the requests and do something useful with them.
   
   When a request arrives, the request handler is called passing in an instance of `HttpServerRequest`. This object
   represents the server side HTTP request.
   
   The handler is called when the headers of the request have been fully read. If the request contains a body,
   that body may arrive at the server some time after the request handler has been called.
   
   It contains functions to get the URI, path, request headers and request parameters. It also contains a
   `response` reference to an object that represents the server side HTTP response for the object.
   
   #### Request Method
   
   The request object has a `method` attribute which returns a string representing what HTTP method was requested. This attribute
   has the type `ceylon.net.http.Method`.
   
   #### Request Version
   
   The request object has a method [[HttpServerRequest.version]] attribute which returns an [[HttpVersion]](enum) representing
   the HTTP version.

   #### Request URI
   
   The request object has an [[HttpServerRequest.uri]] attribute which returns the full URI (Uniform Resource Locator) of the
   request. For example, if the request URI was: `/a/b/c/page.html?param1=abc&param2=xyz` then it would return the corresponding
   `ceylon.net.uri.Uri`. Request URIs can be relative or absolute (with a domain) depending on what the client sent.
   In most cases they will be relative.
   
   #### Request Path
   
   The request object has a [[HttpServerRequest.path]] attribute which returns the path of the request.  For example, if the
   request URI was `/a/b/c/page.html?param1=abc&param2=xyz` then path would return the string `/a/b/c/page.html`
   
   #### Request Query
   
   The request object has a [[HttpServerRequest.query]] which contains the query of the request as a `ceylon.net.uri.Query` object.
   
   #### Request Headers
   
   The request headers are available using the [[HttpServerRequest.headers]] attribute on the request object. The returned
   object is an instance of `Map<String,{String+}>`.
   
   Here's an example that echoes the headers to the output of the response. Run it and point your browser at
   http://localhost:8080 to see the headers.
   
   ~~~
   value server = vertx.createHttpServer();
   void handle(HttpServerRequest request) {
     value sb = StringBuilder();
     for (header in request.headers) {
       for (val in header.item) {
         sb.append("``header.key``: ``val``");
       }
     }
     request.response.end(sb.string);
   }
   server.requestHandler(handle).listen(8080, "localhost);
   ~~~
   
   #### Request params
   
   Similarly to the headers, the request parameters are available using the [[HttpServerRequest.params]] attribute on the request object.
   Request parameters are sent on the request URI, after the path. For example if the URI was:
   
   ~~~
   /page.html?param1=abc&param2=xyz
   ~~~

   Then the params multimap would contain the following entries:
      
   ~~~
   param1: 'abc'
   param2: 'xyz
   ~~~
   
   #### Remote Address
   
   Use the [[HttpServerRequest.remoteAddress]] attribute to find out the address of the other side of the HTTP connection.
   
   #### Absolute URI
   
   Use the method [[HttpServerRequest.absoluteURI]] to return the absolute URI corresponding to the request.

   #### Reading Data from the Request Body
   
   Sometimes an HTTP request contains a request body that we want to read. As previously mentioned the request handler is called when
   only the headers of the request have arrived so the HttpServerRequest object does not contain the body. This is because the body
   may be very large and we don't want to create problems with exceeding available memory.
   
   To receive the body, you need to call the [[HttpServerRequest.parseBody]] method on the request object with a [[BodyType]] implementation.
   This method returns a `Promise<Body>` that will be resolved when the body will be fully parsed, here's an example:
   
   ~~~
   value server = vertx.createHttpServer();
   void handle(HttpServerRequest request) {
     Promise<ByteBuffer> p = request.parseBody(binaryBody);
     p.onComplete((ByteBuffer body) => print("I received ``body.size`` bytes"));
   }
   server.requestHandler(handle).listen(8080, "localhost");
   ~~~
   
   There are several body type implementations:
   
   * [[binaryBody]] : provides a `ceylon.io.ByteBuffer` for any mime type
   * [[textBody]] : provides a Ceylon string for mime type `text/*`
   * [[jsonBody]] : provides a `ceylon.json.Object` for mime type `application/json`
   
   It is of course possible to implement custom [[BodyType]], for instance here is the implementation for text content:
   
   ~~~
   shared object textBody satisfies BodyType<String> {
     shared actual Boolean accept(String mimeType) => mimeType.startsWith("text/");
       shared actual String parse(Charset? charset, Buffer data) {
         if (exists charset) {
           return data.toString(charset.name);
         } else {
           return data.string;
         }
      }
   }
   ~~~
   
   Note that this API is different from the original Vert.x API. Also this current implementation will parse the full body before calling
   the body type object, in the future this will likely evolve to provide a finer granularity for body parsing.
   
   #### Handling Multipart Form Uploads
   
   todo
   
   #### Handling Multipart Form Attributes
   
   If the request corresponds to an HTML form that was submitted you can use the [[HttpServerRequest.formAttributes]] promise to access
   the form attributes. This promise is resolved after all of the request has been read - this is because form attributes are encoded
   in the request body not in the request headers.
   
   ~~~
   req.formAttributes.onComplete((Map<String, {String+}> formAttributes) => print("Do something with them"));
   ~~~
   
   When the request does not have form attributes the `formAttributes` promise is rejected.
   
   ### HTTP Server Responses
   
   As previously mentioned, the HTTP request object contains a [[HttpServerRequest.response]] attribute. This returns the HTTP response
   for the request. You use it to write the response back to the client.
   
   #### Setting Status Code and Message
   
   To set the HTTP status code for the response use the [[HttpServerResponse.status]] method, e.g.
   
   ~~~
   HttpServer server = vertx.createHttpServer();
   void handle(HttpServerRequest request) {
     request.response.status {
       code = 739;
       message = "Too many gerbils";
     }.end();
   }
   server.requestHandler(handle).listen(8080, "localhost");
   ~~~
   
   You can also set the status message. If you do not set the status message a default message will be used.
   
   The default value for the status code is `200`.
   
   ##### Writing HTTP responses
   
   To write data to an HTTP response, you invoke the write function. This function can be invoked multiple times before the response is
   ended. It can be invoked in a few ways:
   
   With a single buffer: currently not supported
   
   A string. In this case the string will encoded using UTF-8 and the result written to the wire.
   
   ~~~
   request.response.write("hello");
   ~~~
   
   A string and an encoding. In this case the string will encoded using the specified encoding and the result written to the wire.
   
   ~~~
   request.response.write(["hello", "UTF-16"]);
   ~~~
   
   The [[HttpServerResponse.write]] function is asynchronous and always returns immediately after the write has been queued.
   If you are just writing a single string or Buffer to the HTTP response you can write it and end the response in a single
   call to the [[HttpServerResponse.end]] method.
   
   The first call to [[HttpServerResponse.write]] results in the response header being being written to the response.
   
   Consequently, if you are not using HTTP chunking then you must set the `Content-Length` header before writing to the response, since
   it will be too late otherwise. If you are using HTTP chunking you do not have to worry.
   
   ##### Ending HTTP responses
   
   Once you have finished with the HTTP response you must call the [[HttpServerResponse.end]] function on it.
   
   This function can be invoked in several ways:
   
   With no arguments, the response is simply ended.
   
   ~~~
   request.response.end();
   ~~~

   The function can also be called with a string or Buffer in the same way [[HttpServerResponse.write]] is called. In this case
   it's just the same as calling write with a string or Buffer (not supported) followed by calling [[HttpServerResponse.end]] with
   no arguments. For example:
   
   ~~~
   request.response.end("That's all folks");
   ~~~
   
   ##### Closing the underlying connection
   
   You can close the underlying TCP connection of the request by calling the [[HttpServerResponse.close]] method.
   
   ~~~
   request.response.close();
   ~~~
   
   ##### Response headers
   
   HTTP response headers can be added to the response by passing them to the [[HttpServerResponse.headers]] methods:
      
   ~~~
   request.response.headers { "Cheese"->"Stilton", "Hat colour"->"Mauve" };
   ~~~
   
   Response headers must all be added before any parts of the response body are written.
   
   ##### Chunked HTTP Responses and Trailers
   
   Vert.x supports [HTTP Chunked Transfer Encoding](http://en.wikipedia.org/wiki/Chunked_transfer_encoding). This allows the HTTP
   response body to be written in chunks, and is normally used when a large response body is being streamed to a client,
   whose size is not known in advance.
   
   You put the HTTP response into chunked mode as follows:
   
   ~~~
   req.response.setChunked(true);
   ~~~
   
   Default is non-chunked. When in chunked mode, each call to `response.write(...)` will result in a new HTTP chunk being written out.
   
   When in chunked mode you can also write HTTP response trailers to the response. These are actually written in the final chunk of the response.
   
   To add trailers to the response, add them to the multimap returned from the trailers() method:
   
   ~~~
   request.response.trailers {
     "Philosophy"->"Solipsism",
     "Favourite-Shakin-Stevens-Song"->"Behind the Green Door"
   };
   ~~~
   
   #### Serving files directly from disk
   
   Not yet implemented.
   
   #### Pumping Responses
   
   The [[HttpServerResponse.stream]] provides a [[io.vertx.ceylon.stream::WriteStream]] you can pump to it from any
   [[io.vertx.ceylon.stream::ReadStream]], e.g. an AsyncFile (todo), NetSocket (todo), WebSocket (todo) or [[HttpServerRequest]].
   
   Here's an example which echoes HttpRequest headers and body back in the HttpResponse. It uses a pump for the body,
   so it will work even if the HTTP request body is much larger than can fit in memory at any one time:
   
   ~~~
   HttpServer server = vertx.createHttpServer();
   void handle(HttpServerRequest request) {
     HttpServerResponse resp = req.response;
     resp.headers(req.headers);
     req.stream.pump(resp.stream).start();
     req.stream.endHandler(resp.close);
   }
   server.requestHandler(handle).listen(8080, "localhost");
   ~~~

   #### HTTP Compression
   
   Not yet available in 2.0.
   
   ### Writing HTTP Clients
   
   #### Creating an HTTP Client
   
   To create an HTTP client you call the [[io.vertx.ceylon::Vertx.createHttpClient]] method on your vertx instance:
   
   ~~~
   HttpClient client = vertx.createHttpClient();
   ~~~
   
   You set the port and hostname (or ip address) that the client will connect to using the [[HttpClient.host]] and [[HttpClient.port]] attributes:
   
   ~~~
   HttpClient client = vertx.createHttpClient();
   client.port = 8181;
   client.host = "foo.com";
   ~~~
   
   You can also set the port and host when creating the client:
   
   ~~~
   HttpClient client = vertx.createHttpClient {
     port = 8181;
     host = "foo.com";
   };
   ~~~

   A single [[HttpClient]] always connects to the same host and port. If you want to connect to different servers, create more instances.

   The default port is `80` and the default host is `localhost`. So if you don't explicitly set these values that's what the client
   will attempt to connect to.
   
   #### Pooling and Keep Alive
   
   By default the [[HttpClient]] pools HTTP connections. As you make requests a connection is borrowed from the pool and returned
   when the HTTP response has ended.
   
   If you do not want connections to be pooled you can set [[HttpClient.keepAlive]] to false:
   
   ~~~
   HttpClient client = vertx.createHttpClient();
   client.port = 8181;
   client.host = "foo.com";
   client.keepAlive = false;
   ~~~
   
   In this case a new connection will be created for each HTTP request and closed once the response has ended.
   
   You can set the maximum number of connections that the client will pool as follows:
   
   ~~~
   HttpClient client = vertx.createHttpClient();
   client.port = 8181;
   client.host = "foo.com";
   client.maxPoolSize = 10;
   ~~~
   
   The default value is `1`.
   
   #### Closing the client
   
   Any HTTP clients created in a verticle are automatically closed for you when the verticle is stopped, however if you want to close
   it explicitly you can:
   
   ~~~
   client.close();
   ~~~
   
   #### Making Requests
   
   To make a request using the client you invoke one the methods named after the HTTP method that you want to invoke.
   
   For example, to make a `POST` request:
   
   ~~~
   value client = vertx.createHttpClient{ host = "foo.com" };
   HttpClientRequest request = client.post("/some-path"/);
   request.response.onComplete((HttpClientResponse resp) => print("Got a response: ``resp.status``"));
   request.end();
   ~~~
   
   To make a PUT request use the [[HttpClient.put]] method, to make a GET request use the [[HttpClient.get]] method, etc.

   Legal request methods are: [[HttpClient.get]], [[HttpClient.put]], [[HttpClient.post]], [[HttpClient.delete]], [[HttpClient.head]],
   [[HttpClient.options]], [[HttpClient.connect]], [[HttpClient.trace]] and [[HttpClient.patch]].
   
   The general modus operandi is you invoke the appropriate method passing in the request URI. The `Promise<HttpClientResponse` [[HttpClientRequest.response]]]
   attribute will be resolved when the corresponding response arrives. Note that the response promise should be used before the [[HttpClientRequest.end]]
   method is called, so the promise will be resolved by the Vert.x thread.
   
   The value specified in the request URI corresponds to the Request-URI as specified in
   [Section 5.1.2 of the HTTP specification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html). _In most cases it will be a relative URI_.
   
   _Please note that the domain/port that the client connects to is determined by [[HttpClient.port]] and [[HttpClient.host]], and is not parsed
   from the uri._
   
   The return value from the appropriate request method is an instance of [[HttpClientRequest]]. You can use this to add headers to the request,
   and to write to the request body. The request object implements [[io.vertx.ceylon.stream::WriteStream]].

   Once you have finished with the request you must call the [[HttpClientRequest.end]] method.

   If you don't know the name of the request method in advance there is a general [[HttpClient.request]] method which takes the HTTP
   method as a parameter:
         
   ~~~
   value client = vertx.createHttpClient{ host = "foo.com" };
   value request = client.request(post, "/some-path/");
   request.response.onComplete((HttpClientResponse resp) => print("Got a response: ``resp.status``"));
   request.end();
   ~~~

   ##### Handling exceptions
   
   The [[HttpClientRequest.response]] promise will be rejected when the request fails.
   
   ##### Writing to the request body
   
   Writing to the client request body has a very similar API to writing to the server response body.
   
   To write data to an [[HttpClientRequest]] object, you invoke the [[HttpClientRequest.write]] function. This function can be called multiple times
   before the request has ended. It can be invoked in a few ways:
   
   With a single buffer: (todo)
   
   A string. In this case the string will encoded using UTF-8 and the result written to the wire:
   
   ~~~
   request.write("hello");
   ~~~
   
   A string and an encoding. In this case the string will encoded using the specified encoding and the result written to the wire.
   
   ~~~
   request.write("hello", "UTF-16");
   ~~~
   
   The [[HttpClientRequest.write]] function is asynchronous and always returns immediately after the write has been queued.
   The actual write might complete some time later.
   
   If you are just writing a single string or Buffer to the HTTP request you can write it
   and end the request in a single call to the end function.

   The first call to `write` will result in the request headers being written to the request. Consequently, if you are not
   using HTTP chunking then you must set the `Content-Length` header before writing to the request, since it will be too
   late otherwise. If you are using HTTP chunking you do not have to worry.

   ##### Ending HTTP requests
   
   Once you have finished with the HTTP request you must call the [[HttpClientRequest.end]] function on it.
   
   This function can be invoked in several ways:
   
   With no arguments, the request is simply ended.
   
   ~~~
   request.end();
   ~~~
   
   The function can also be called with a string or Buffer in the same way `write` is called. In this case it's just the
   same as calling write with a string or Buffer followed by calling `end` with no arguments.
   
   ##### Writing Request Headers
   
   To write headers to the request, add them using the [[HttpClientRequest.headers]] method:
   
   ~~~
   value client = vertx.createHttpClient{ host = "foo.com" };
   value request = client.request(post, "/some-path/");
   request.response.onComplete((HttpClientResponse resp) => print("Got a response: ``resp.status``"));
   request.headers { "Some-Header"->"Some-Value" };
   request.end();
   ~~~
   
   ##### Request timeouts
   
   You can set a timeout for specific Http Request using the [[HttpClientRequest.timeout]] attribute. If the request does not
   return any data within the timeout period the [[HttpClientRequest.response]] will be rejected and the request will be closed.
   
   ##### HTTP chunked requests
   
   Vert.x supports [HTTP Chunked Transfer Encoding](http://en.wikipedia.org/wiki/Chunked_transfer_encoding) for requests. This allows the
   HTTP request body to be written in chunks, and is normally used when a large request body is being streamed to the server,
   whose size is not known in advance.
   
   You put the HTTP request into chunked mode as follows:
   
   ~~~
   request.chunked = true;
   ~~~
   
   Default is non-chunked. When in chunked mode, each call to request.write(...) will result in a new HTTP chunk being written out.

   #### HTTP Client Responses
   
   Client responses are received as an argument to the response handler that is passed into one of the request methods on the HTTP client.
   
   The response object provides a [[HttpClientResponse.stream]] attribute, so it can be pumped to a
   [[io.vertx.ceylon.stream::WriteStream]] like any other [[io.vertx.ceylon.stream::ReadStream]].
   
   To query the status code of the response use the [[HttpClientResponse.statusMessage]] attribute. The
   [[HttpClientResponse.statusMessage]] attribute contains the status message. For example:

   ~~~
   value client = vertx.createHttpClient{ host = "foo.com" };
   value request = client.request(post, "/some-path/");
   request.response.onComplete {
     void onFulfilled(HttpClientResponse resp) {
       print("server returned status code: ``resp.statusCode``");
       print("server returned status message: ``resp.statusMessage``");
     }
   };
   request.end();
   ~~~
   
   ##### Reading Data from the Response Body
   
   The API for reading an HTTP client response body is very similar to the API for reading a HTTP server request body.
   
   Sometimes an HTTP response contains a body that we want to read. Like an HTTP request, the client response promise
   is resolved when all the response headers have arrived, not when the entire response body has arrived.
   
   To receive the response body, you use the [[HttpClientResponse.parseBody]] on the response object which returns a `Promise<Body>`
   that is resolved when the response body has been parsed. Here's an example:
   
   ~~~
   value client = vertx.createHttpClient{ host = "foo.com" };
   value request = client.request(post, "/some-path/");
   request.response.onComplete((HttpClientResponse resp) => resp.parseBody(binaryBody).onComplete((ByteBuffer body) => print("I received  + ``body.size`` + bytes")));
   request.end();
   ~~~
   
   The response object provides the [[HttpClientResponse.stream]] interface so you can pump the response body to a
   [[io.vertx.ceylon.stream::WriteStream]]. See the chapter on streams and pump for a detailed explanation.
   
   ##### Reading cookies
   
   You can read the list of cookies from the response using the [[HttpClientResponse.cookies]] attribute.
   
   #### 100-Continue Handling
   
   todo
   
   #### HTTP Compression
   
   Not provided by the 2.0 API
   
   ### Pumping Requests and Responses
   
   The HTTP client and server requests and responses all implement either [[io.vertx.ceylon.stream::ReadStream]] or [[io.vertx.ceylon.stream::ReadStream]].
   This means you can pump between them and any other read and write streams.

   ### HTTPS Servers
   
   todo
   
   ### HTTPS Clients
   
   todo
   
   ### Scaling HTTP servers
   
   Scaling an HTTP or HTTPS server over multiple cores is as simple as deploying more instances of the verticle. For example:

   ~~~
   vertx runmod com.mycompany~my-mod~1.0 -instance 20
   ~~~
   
   Or, for a raw verticle:

   ~~~
   vertx run foo.MyServer -instances 20
   ~~~
   
   The scaling works in the same way as scaling a NetServer. Please see the chapter on scaling Net Servers for a detailed
   explanation of how this works.
   
   ## Routing HTTP requests with Pattern Matching
   
   Vert.x lets you route HTTP requests to different handlers based on pattern matching on the request path. It also enables you
   to extract values from the path and use them as parameters in the request.
   
   This is particularly useful when developing REST-style web applications.
   
   To do this you simply create an instance of [[RouteMatcher]] and use it as handler in an HTTP server.
   See the chapter on HTTP servers for more information on setting HTTP handlers. Here's an example:
   
   ~~~
   value server = vertx.createHttpServer();
   value routeMatcher = RouteMatcher();
   server.requestHandler(routeMatcher.handle).listen { port = 8080; host = "localhost"; };
   ~~~
   
   ### Specifying matches.
   
   You can then add different matches to the route matcher. For example, to send all GET requests with path `/animals/dogs` to
   one handler and all GET requests with path `/animals/cats` to another handler you would do:
   
   ~~~
   value server = vertx.createHttpServer();
   value routeMatcher = RouteMatcher();
   routerMarcher.get("/animals/dogs", (HttpServerRequest req) => req.response().end("You requested dogs"));
   routerMarcher.get("/animals/cats", (HttpServerRequest req) => req.response().end("You requested cats"));
   server.requestHandler(router.handle).listen { port = 8080; host = "localhost"; };
   ~~~
   
   Corresponding methods exist for each HTTP method - `get`, `post`, `put`, `delete`, `head`, `options`, `trace`, `connect` and `patch`.

   There's also an `all` method which applies the match to any HTTP request method.
   
   The handler specified to the method is just a normal HTTP server request handler, the same as you would supply to the
   requestHandler method of the HTTP server.
   
   You can provide as many matches as you like and they are evaluated in the order you added them, the first matching
   one will receive the request.

   A request is sent to at most one handler.
   
   ### Extracting parameters from the path
   
   If you want to extract parameters from the path, you can do this too, by using the : (colon) character to denote
   the name of a parameter. For example:

   ~~~
   value server = vertx.createHttpServer();
   value routeMatcher = RouteMatcher();
   routerMarcher.get {
     pattern = "/:blogname/:post";
     void handler(HttpServerRequest req) {
       assert(exists blogName = req.params["blogname"]);
       assert(exists post = req.params["post"]);
       req.response.end("blogname is ``blogName`` post is ``post``");
     }
   };
   server.requestHandler(router.handle).listen { port = 8080; host = "localhost"; };
   ~~~
   
   Any params extracted by pattern matching are added to the map of request parameters.
   
   In the above example, a PUT request to `/myblog/post1 would result in the variable `blogName` getting the value `myblog` and the
   variable `post` getting the value `post1`.
   
   Valid parameter names must start with a letter of the alphabet and be followed by any letters of the alphabet or digits or
   the underscore character.
   
   ### Extracting params using Regular Expressions
   
   Regular Expressions can be used to extract more complex matches. In this case capture groups are used to capture any parameters.
   
   Since the capture groups are not named they are added to the request with names `param0`, `param1`, `param2`, etc.
   
   Corresponding methods exist for each HTTP method - [[RouteMatcher.getWithRegEx]], [[RouteMatcher.postWithRegEx]], [[RouteMatcher.putWithRegEx]],
   [[RouteMatcher.deleteWithRegEx]], [[RouteMatcher.headWithRegEx]], [[RouteMatcher.optionsWithRegEx]], [[RouteMatcher.traceWithRegEx]],
   [[RouteMatcher.connectWithRegEx]] and [[RouteMatcher.patchWithRegEx]].
   
   There's also an [[RouteMatcher.allWithRegEx]] method which applies the match to any HTTP request method.
   
   For example:

   ~~~
   value server = vertx.createHttpServer();
   value routeMatcher = RouteMatcher();
   routerMarcher.get {
     pattern = "\\/([^\\/]+)\\/([^\\/]+)";
     void handler(HttpServerRequest req) {
       assert(exists first = req.params["param0"]);
       assert(exists second = req.params["param1"]);
       req.response.end("first is ``first`` and second is ``second``");
     }
   };
   server.requestHandler(router.handle).listen { port = 8080; host = "localhost"; };
   ~~~
   
   Run the above and point your browser at `http://localhost:8080/animals/cats`.
   
   ### Handling requests where nothing matches
   
   You can use the [[RouteMatcher.noMatch]] method to specify a handler that will be called if nothing matches.
   If you don't specify a no match handler and nothing matches, a 404 will be returned.

   ~~~
   routeMatcher.noMatch((HttpServerRequest req) => req.response.end("Nothing matched"));
   ~~~
   
   ### WebSockets
   
   [WebSockets](http://en.wikipedia.org/wiki/WebSocket) are a web technology that allows a full duplex
   socket-like connection between HTTP servers and HTTP clients (typically browsers).
   
   #### WebSockets on the server
   
   To use WebSockets on the server you create an HTTP server as normal, but instead of setting a
   `requestHandler` you set a `websocketHandler` on the server.
   
   ~~~
   value server = vertx.createHttpServer();
   
   server.websocketHandler {
     void handle(ServerWebSocket ws) {
       // A WebSocket has connected!
     }
   }.listen(8080, "localhost");
   ~~~
   
   ##### Reading from and Writing to WebSockets
   
   The `websocket` instance passed into the handler provides access to the [[io.vertx.ceylon.stream::ReadStream]] and
   [[io.vertx.ceylon.stream::WriteStream]], so you can read and write data to it in the normal ways. I.e by setting a
   [[io.vertx.ceylon.stream::ReadStream.dataHandler]] and calling the [[io.vertx.ceylon.stream::WriteStream.write]]
   method.
   
   See the chapter on streams and pumps for more information.
   
   For example, to echo all data received on a WebSocket:
   
   ~~~
   value server = vertx.createHttpServer();
   
   server.websocketHandler {
     void handle(ServerWebSocket ws) {
       value pump = ws.readStream.pump(ws.writeStream);
       pump.start();
    }
   }.listen(8080, "localhost");
   ~~~
   
   The `websocket instance also has method `writeBinaryFrame` for writing binary data. This has the same effect
   as calling `write`.
   
   Another method `writeTextFrame` also exists for writing text data. This is equivalent to calling
   
   ~~~
   websocket.write(Buffer("some-string"));
   ~~~
   
   ##### Rejecting WebSockets
   
   Sometimes you may only want to accept WebSockets which connect at a specific path.
   
   To check the path, you can query the [[ServerWebSocket.path]] attribute of the websocket. You can then call
   the [[ServerWebSocket.reject]] method to reject the websocket.
   
   ~~~
   value server = vertx.createHttpServer();
   
   server.websocketHandler { 
     void handle(ServerWebSocket ws) {
       if (ws.path().equals("/services/echo")) {
         value pump = ws.readStream.pump(ws.writeStream);
         pump.start();
       } else {
         ws.reject();
       }
     }
   }.listen(8080, "localhost");
   ~~~
   
   ##### Headers on the websocket
   
   You can use the [[ServerWebSocket.headers]] method to retrieve the headers passed in the Http Request
   from the client that caused the upgrade to websockets.
   
   #### WebSockets on the HTTP client
   
   To use WebSockets from the HTTP client, you create the HTTP client as normal, then call the
   [[HttpClient.connectWebsocket]] function, passing in the URI that you wish to connect to at the
   server, and a handler.
   
   The handler will then get called if the WebSocket successfully connects. If the WebSocket does not
   connect - perhaps the server rejects it - then any exception handler on the HTTP client will be called.
   
   Here's an example of WebSocket connection:
   
   ~~~
   value client = vertx.createHttpClient();
   client.host = "foo.com";
   
   client.connectWebsocket("/some-uri", (WebSocket ws) => print("Connected!) });
   ~~~
   
   Note that the host (and port) is set on the [[HttpClient]] instance, and the uri passed in the connect is
   _typically_ a relative URI.

   Again, the client side WebSocket implements [[io.vertx.ceylon.stream::ReadStream]] and [[io.vertx.ceylon.stream::WriteStream]],
   so you can read and write to it in the same way as any other stream object.
      """
by("Julien Viet")
shared package io.vertx.ceylon.http;
