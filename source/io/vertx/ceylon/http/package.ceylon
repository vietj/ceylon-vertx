import ceylon.promises { Promise }
import ceylon.io.charset { Charset }
import org.vertx.java.core.buffer { Buffer }
/*
 * Copyright 2013 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
      then_(
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
   
   #### Query params
   
   Similarly to the headers, the request parameters are available using the [[HttpServerRequest.queryParameters]] attribute on
   the request object. The returned object is an instance of `Map<String, {String+}>`. Request parameters are sent on the request URI,
   after the path. For example if the URI was `/page.html?param1=abc&param2=xyz`, then the query params map would contain the following entries:
   
   ~~~
   param1: 'abc'
   param2: 'xyz
   ~~~
   
   #### Form params
   
   When the request is a post with the `application/x-www-form-urlencoded` mime type then the parameters are parsed and made available
   using the [[HttpServerRequest.formParameters]] attribute. Note that this does not exist in the original Vert.x API.
   
   #### Request params
   
   The [[HttpServerRequest.parameters]] attribute is an aggregate of the [[HttpServerRequest.queryParameters]] and the [[HttpServerRequest.formParameters]]
   attributes. Note that this does not exist in the original Vert.x API.
   
   #### Remote Address
   
   Use the [[HttpServerRequest.remoteAddress]] attribute to find out the address of the other side of the HTTP connection.

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
     p.then_((ByteBuffer body) => print("I received ``body.size`` bytes"));
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
   
   Not yet implemented.
   
   #### HTTP Compression
   
   Not yet available in 2.0.
   
   ### Writing HTTP Clients
   
   Todo.
   """
by("Julien Viet")
shared package io.vertx.ceylon.http;
