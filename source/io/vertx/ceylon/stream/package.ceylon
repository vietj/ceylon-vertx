"""# Flow Control - Streams and Pumps
   
   There are several objects in Vert.x that allow data to be read from and written to in the form of Buffers.
   
   In Vert.x, calls to write data return immediately and writes are internally queued.
   
   It's not hard to see that if you write to an object faster than it can actually write the data to its
   underlying resource then the write queue could grow without bound - eventually resulting in exhausting available memory.
   
   To solve this problem a simple flow control capability is provided by some objects in the Vert.x API.
   
   Any flow control aware object that can be written-to provides a [[ReadStream]], and any flow control object that can be
   read-from is said to provides a [[WriteStream]].
   
   Let's take an example where we want to read from a `ReadStream` and write the data to a `WriteStream`.
   
   A very simple example would be reading from a [[io.vertx.ceylon.net::NetSocket]] on a server and writing back to
   the same [[io.vertx.ceylon.net::NetSocket]] - since [[io.vertx.ceylon.net::NetSocket]] provides both [[ReadStream]] and
   [[WriteStream]], but you can do this between any [[ReadStream]] and any [[WriteStream]], including HTTP requests
   and response, async files, WebSockets, etc.
   
   A naive way to do this would be to directly take the data that's been read and immediately write it to the NetSocket, for example:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.dataHandler {
         void onData(Buffer buffer) {
           // Write the data straight back
           sock.write(buffer);
         }
       }
     }
   }.listen(1234, "localhost");
   ~~~
   
   There's a problem with the above example: If data is read from the socket faster than it can be written back
   to the socket, it will build up in the write queue of the [[io.vertx.ceylon.net::NetSocket]], eventually running out of RAM.
   This might happen, for example if the client at the other end of the socket wasn't reading very fast,
   effectively putting back-pressure on the connection.
   
   Since NetSocket provides [[WriteStream]], we can check if the [[WriteStream]] is full before writing to it:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.dataHandler {
         void onData(Buffer buffer) {
           if (!sock.writeStream) {
             sock.write(buffer);
           }
         }
       }
     }
   }.listen(1234, "localhost");
   ~~~
   
   This example won't run out of RAM but we'll end up losing data if the write queue gets full. What we really want
   to do is pause the [[io.vertx.ceylon.net::NetSocket]] when the write queue is full. Let's do that:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.dataHandler {
         void onData(Buffer buffer) {
           if (!sock.writeStream) {
             sock.write(buffer);
           } else {
             sock.writeStream.pause();
         }
       }
     }
   }.listen(1234, "localhost");
   ~~~
   
   We're almost there, but not quite. The `NetSocket` now gets paused when the file is full, but we also need to
   unpause it when the write queue has processed its backlog:

   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.dataHandler {
         void onData(Buffer buffer) {
           if (!sock.writeStream) {
             sock.write(buffer);
           } else {
             sock.readStream.pause();
             sock.writeStream.drainHandler {
               void onDrain() {
                 sock.readStream.resume();
               }
             };
           }
         }
       }
     }
   }.listen(1234, "localhost");
   ~~~
   
   And there we have it. The [[WriteStream.drainHandler]] event handler will get called when the write queue is
   ready to accept more data, this resumes the NetSocket which allows it to read more data.
   
   It's very common to want to do this when writing Vert.x applications, so we provide a helper class called [[Pump]] which
   does all this hard work for you. You just feed it the [[ReadStream]] and the [[WriteStream]] and it tell it to start:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       Pump(sock, sock).start();
     }
   }.listen(1234, "localhost");
   ~~~
   
   Which does exactly the same thing as the more verbose example.
   
   Let's look at the methods on [[ReadStream]] and [[WriteStream]] in more detail:

   ## ReadStream
   
   [[ReadStream]] is provided by `HttpClientResponse`, `HttpServerRequest`, `WebSocket`, `NetSocket`, `SockJSSocket` and `AsyncFile`.
   
   - [[ReadStream.dataHandler]] set a handler which will receive data from the `ReadStream`. As data arrives the handler will be passed a Buffer.
   - [[ReadStream.pause]] pause the handler. When paused no data will be received in the `dataHandler`.
   - [[ReadStream.resume]] resume the handler. The handler will be called if any data arrives.
   - [[ReadStream.exceptionHandler]] Will be called if an exception occurs on the `ReadStream`.
   - [[ReadStream.endHandler]] Will be called when end of stream is reached. This might be when EOF is reached if the `ReadStream`
    represents a file, or when end of request is reached if it's an HTTP request, or when the connection is closed if it's a TCP socket.
   
   ## WriteStream
   
   [[WriteStream]] is provided by , `HttpClientRequest`, `HttpServerResponse`, `WebSocket`, `NetSocket`, `SockJSSocket` and `AsyncFile`.
   
   - [[WriteStream.write]] write a Buffer to the `WriteStream`. This method will never block. Writes are queued internally and asynchronously written to the underlying resource.
   - [[WriteStream.setWriteQueueMaxSize]] set the number of bytes at which the write queue is considered _full_, and the method
   `writeQueueFull()` returns `true`. Note that, even if the write queue is considered full, if `write is called the data will still be accepted and queued.
   - [[WriteStream.writeQueueFull]] returns `true` if the write queue is considered full.
   - [[WriteStream.exceptionHandler]] Will be called if an exception occurs on the `WriteStream`.
   - [[WriteStream.drainHandler]] The handler will be called if the `WriteStream` is considered no longer full.
   
   ## Pump
   
   Instances of Pump have the following methods:
   
   - [[Pump.start]] Start the pump.
   - [[Pump.stop]] Stops the pump. When the pump starts it is in stopped mode.
   - [[Pump.setWriteQueueMaxSize]] This has the same meaning as [[WriteStream.setWriteQueueMaxSize]].
   - [[Pump.bytesPumped]] Returns total number of bytes pumped.
   
   A pump can be started and stopped multiple times.
   
   When a pump is first created it is _not_ started. You need to call the [[Pump.start]] method to start it.
   """
shared package io.vertx.ceylon.stream;
