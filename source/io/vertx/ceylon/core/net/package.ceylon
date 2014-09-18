"""# Writing TCP Servers and Clients
   
   Creating TCP servers and clients is very easy with Vert.x.
   
   ## Net Server
   
   ### Creating a Net Server
   
   To create a TCP server you call the [[io.vertx.ceylon.core::Vertx.createNetServer]] method on your vertx instance.
   
   ~~~
   value server = vertx.createNetServer();
   ~~~
   
   ### Start the Server Listening
   
   To tell that server to listen for connections we do:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.listen(1234, "myhost");
   ~~~
   
   The first parameter to [[NetServer.listen]] is the port. A wildcard port of `0` can be specified which means a random
   available port will be chosen to actually listen at. Once the server has completed listening you can then call
   the [[NetServer.port]] attribute of the server to find out the real port it is using.
   
   The second parameter is the hostname or ip address. If it is omitted it will default to `0.0.0.0` which means it
   will listen at all available interfaces.
   
   The actual bind is asynchronous so the server might not actually be listening until some time after the call to
   listen has returned. If you want to be notified when the server is actually listening you can use the returned
   promise. For example:
   
   ~~~
   value result = server.listen(1234);
   value.onComplete {
     void onFulfilled(NetServer server) {
       print(""Listen succeeded");
     },
     void onRejected(Throwable reason) {
       print(""Listen failed");
     }
   };
   ~~~
   
   ### Getting Notified of Incoming Connections
   
   To be notified when a connection occurs we need to call the [[NetServer.connectHandler]] method of the server, passing
   in a handler. The handler will then be called when a connection is made:
   
   ~~~
   value server = vertx.createNetServer();

   server.connectHandler {
     void onConnect(NetSocket sock) {
       print("A client has connected!");
     }
   };
   
   server.listen(1234, "localhost");
   ~~~
   
   That's a bit more interesting. Now it displays 'A client has connected!' every time a client connects.
   
   The return value of the [[NetServer.connectHandler]] method is the server itself, so multiple invocations can be
   chained together. That means we can rewrite the above as:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       print("A client has connected!");
     }
   }.listen(1234, "localhost");
   ~~~
   
   or 

   ~~~
   vertx.createNetServer().connectHandler {
     void onConnect(NetSocket sock) {
       print("A client has connected!");
     }
   }.listen(1234, "localhost");
   ~~~
   
   This is a common pattern throughout the Vert.x API.
   
   ### Closing a Net Server
   
   To close a net server just call the [[NetServer.close]] function.
   
   ~~~
   server.close();
   ~~~
   
   he close is actually asynchronous and might not complete until some time after the [[NetServer.close]] method has returned.
   If you want to be notified when the actual close has completed then you can use the returned promise.
   
   This promise will then be fulfilled when the close has fully completed.
   
   ~~~
   server.close().onComplete {
     void onFulfilled(Null n) {
       print("Close succeeded");
     },
     void onRejected(Throwable reason) {
       print("Close failed");
     }
   };
   ~~~
   
   If you want your net server to last the entire lifetime of your verticle, you don't need to call [[NetServer.close]]
   explicitly, the Vert.x container will automatically close any servers that you created when the verticle is undeployed.
   
   ### NetServer Properties
   
   NetServer has a set of properties you can set which affect its behaviour. Firstly there are bunch of properties used
   to tweak the TCP parameters, in most cases you won't need to set these:
   
   - [[io.vertx.ceylon.core::ServerBase.tcpNoDelay]] If true then [Nagle's Algorithm](http://en.wikipedia.org/wiki/Nagle's_algorithm) is disabled. If false then it is enabled.
   - [[io.vertx.ceylon.core::NetworkBase.sendBufferSize]] Sets the TCP send buffer size in bytes.   
   - [[io.vertx.ceylon.core::NetworkBase.receiveBufferSize]] Sets the TCP receive buffer size in bytes.
   - [[io.vertx.ceylon.core::ServerBase.tcpKeepAlive]] if tcpKeepAlive is true then TCP keep alive is enabled, if false it is disabled.
   - [[io.vertx.ceylon.core::NetworkBase.reuseAddress]] if reuse is true then addresses in TIME_WAIT state can be reused after they have been closed.
   - [[io.vertx.ceylon.core::ServerBase.soLinger]]
   - [[io.vertx.ceylon.core::NetworkBase.trafficClass]]

   [[NetServer]] has a further set of properties which are used to configure SSL. We'll discuss those later on.
         
   ### Handling Data
   
   So far we have seen how to create a NetServer, and accept incoming connections, but not how to do anything interesting
   with the connections. Let's remedy that now.
   
   When a connection is made, the [[NetServer.connectHandler]] is called passing in an instance of [[NetSocket]]. This is a socket-like
   interface to the actual connection, and allows you to read and write data as well as do various other things like close the socket.
   
   #### Reading Data from the Socket
   
   To read data from the socket you need to set the [[io.vertx.ceylon.core.stream::ReadStream.dataHandler]] on the [[NetSocket.readStream]].
   This handler will be called with an instance of [[org.vertx.java.core.buffer::Buffer]] every time data is received on the
   socket. You could try the following code and telnet to it to send some data:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.readStream.dataHandler {
         void onData(Buffer buffer) {
           print("I received ``buffer.length()`` bytes of data"));
         }
       }
     }
   }.listen(1234, "localhost");;
   ~~~
   
   #### Writing Data to a Socket
   
   To write data to a socket, you invoke the [[NetSocket.write]] function. This function can be invoked in a few ways:

   With a single buffer:
   
   ~~~
   value myBuffer = Buffer(...);
   sock.write(myBuffer);
   ~~~

   A string. In this case the string will encoded using UTF-8 and the result written to the wire.
   
   ~~~
   sock.write("hello");
   ~~~
   
   A string and an encoding. In this case the string will encoded using the specified encoding and the result written to the wire.
   
   ~~~
   sock.write(["hello", "UTF-16"]);
   ~~~
   
   The [[NetSocket.write]] function is asynchronous and always returns immediately after the write has been queued. Let's put it all together.
   
   Here's an example of a simple TCP echo server which simply writes back (echoes) everything that it receives on the socket:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.readStream.dataHandler {
         void onData(Buffer buffer) {
           sock.write(buffer);
         }
       }
     }
   }.listen(1234, "localhost");;
   ~~~
   
   #### Socket Remote Address
   
   You can find out the remote address of the socket (i.e. the address of the other side of the TCP IP connection) by calling
   [[NetSocket.remoteAddress]].
   
   #### Socket Local Address
   
   You can find out the local address of the socket (i.e. the address of this side of the TCP IP connection) by calling
   [[NetSocket.localAddress]].
   
   #### Closing a socket
   
   You can close a socket by invoking the [[NetSocket.close]] method. This will close the underlying TCP connection.
   
   #### Closed Handler
   
   If you want to be notified when a socket is closed, you can use the [[NetSocket.closeHandler]] promise:
   
   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.closeHandler.onComplete {
         void onFulfilled(Null n) {
           print("The socket is now closed");
         }
       }
     }
   }.listen(1234, "localhost");;
   ~~~
   
   The closed handler will be called irrespective of whether the close was initiated by the client or server.
   
   #### Exception handler
   
   You can set an exception handler on the socket that will be called if an exception occurs asynchronously on the connection:

   ~~~
   value server = vertx.createNetServer();
   
   server.connectHandler {
     void onConnect(NetSocket sock) {
       sock.readStream.exceptionHandler {
         void onException(Throwable cause) {
           print("Oops, something went wrong");
           t.printStackTrace();
         }
       }
     }
   }.listen(1234, "localhost");;
   ~~~
   
   #### Event Bus Write Handler
   
   Every NetSocket automatically registers a handler on the event bus, and when any buffers are received in this handler,
   it writes them to itself. This enables you to write data to a NetSocket which is potentially in a completely different
   verticle or even in a different Vert.x instance by sending the buffer to the address of that handler.
   
   The address of the handler is given by the [[NetSocket.writeHandlerID]] attribute.
   
   For example to write some data to the NetSocket from a completely different verticle you could do:
   
   ~~~
   String writeHandlerID = ... // E.g. retrieve the ID from shared data
   
   vertx.eventBus().send(writeHandlerID, buffer);
   ~~~
   
   #### Read and Write Streams
   
   NetSocket provide access to [[io.vertx.ceylon.core.net::NetSocket.readStream]] and [[io.vertx.ceylon.core.net::NetSocket.writeStream]].
   This allows flow control to occur on the connection and the connection data to be pumped to and from other object such
   as HTTP requests and responses, WebSockets and asynchronous files.
   
   This will be discussed in depth in the chapter on streams and pumps.
   
   ### Scaling TCP Servers
   
   A verticle instance is strictly single threaded.
   
   If you create a simple TCP server and deploy a single instance of it then all the handlers for that server are
   always executed on the same event loop (thread).
   
   This means that if you are running on a server with a lot of cores, and you only have this one instance deployed
   then you will have at most one core utilised on your server!
   
   To remedy this you can simply deploy more instances of the module in the server, e.g.
   
   ~~~
   vertx runmod com.mycompany~my-mod~1.0 -instances 20
   ~~~
   
   Or for a raw verticle
   
   ~~~
   vertx run foo.MyApp -instances 20
   ~~~

   The above would run 20 instances of the module/verticle in the same Vert.x instance.
   
   Once you do this you will find the echo server works functionally identically to before, but, as if by magic, all your
   cores on your server can be utilised and more work can be handled.
   
   At this point you might be asking yourself '_Hold on, how can you have more than one server listening on the same host and
   port? Surely you will get port conflicts as soon as you try and deploy more than one instance?_'
   
   Vert.x does a little magic here.
   
   When you deploy another server on the same host and port as an existing server it doesn't actually try and create
   a new server listening on the same host/port.
   
   Instead it internally maintains just a single server, and, as incoming connections arrive it distributes
   them in a round-robin fashion to any of the connect handlers set by the verticles.
   
   Consequently Vert.x TCP servers can scale over available cores while each Vert.x verticle instance remains
   strictly single threaded, and you don't have to do any special tricks like writing load-balancers in order to
   scale your server on your multi-core machine.
   
   ## Net Client
   
   A NetClient is used to make TCP connections to servers.
   
   ### Creating a Net Client
   
   To create a TCP client you call the [[io.vertx.ceylon.core::Vertx.createNetClient]] method on your vertx instance.
   
   ~~~
   value Netclient = vertx.createNetClient();
   ~~~
   
   ### Making a Connection
   
   To actually connect to a server you invoke the [[NetClient.connect]] method:
      
   ~~~
   value Netclient = vertx.createNetClient();
   
   Promise<NetSocket> connect = client.connect(1234, "localhost");
   connect.onComplete {
     void onFulfilled(NetSocket socket) {
       print(""We have connected! Socket is ``socket``");
     },
     void onRejected(Throwable reason) {
       reason.printStackTrace();
     }
   };
   ~~~
   
   The connect method takes the port number as the first parameter, followed by the hostname or ip address of
   the server. The third parameter is a connect handler. This handler will be called when the connection actually occurs.
   
   The argument returned by [[NetClient.connect]] is a `Promise<NetSocket>` fulfilled with the [[NetSocket]]. You can read
   and write data from the socket in exactly the same way as you do on the server side.
   
   You can also close it, set the closed handler, set the exception handler and use it as a `ReadStream` or `WriteStream`
   exactly the same as the server side [[NetSocket]].

   ### Configuring Reconnection
   
   A NetClient can be configured to automatically retry connecting or reconnecting to the server in the event that it
   cannot connect or has lost its connection. This is done by setting the [[NetClient.reconnectAttempts]] and
   [[NetClient.reconnectInterval]] attributes:
   
   ~~~
   value client = vertx.createNetClient();
   client.reconnectAttempts = 1000;
   client.reconnectInterval = 500;
   ~~~
   
   `reconnectAttempts` determines how many times the client will try to connect to the server before giving up
    A value of `-1` represents an infinite number of times. The default value is `0`. I.e. no reconnection is attempted.
   
   `reconnectInterval` detemines how long, in milliseconds, the client will wait between reconnect attempts. The default
   value is `1000`.
   
   ### NetClient Properties
   
   Just like [[NetServer]], [[NetClient]] also has a set of TCP properties you can set which affect its behaviour.
   They have the same meaning as those on [[NetServer]].
   
   [[NetClient]] also has a further set of properties which are used to configure SSL. We'll discuss those later on.
   
   ## SSL Servers
   
   Net servers can also be configured to work with [Transport Layer Security](http://en.wikipedia.org/wiki/Transport_Layer_Security) (previously known as SSL).
   
   When a [[NetServer]] is working as an SSL Server the API of the [[NetServer]] and [[NetSocket]] is identical compared to
   when it working with standard sockets. Getting the server to use SSL is just a matter of configuring the [[NetServer]]
   before [[NetServer.listen]] is called.
   
   To enabled SSL the attribute [[io.vertx.ceylon.core::ServerBase.ssl]] must be called on the Net Server.
   
   The server must also be configured with a _key store_ and an optional _trust store_.
   
   These are both _Java keystores_ which can be managed using the [keytool](http://docs.oracle.com/javase/6/docs/technotes/tools/solaris/keytool.html)
   utility which ships with the JDK.
   
   The keytool command allows you to create keystores, and import and export certificates from them.
   
   The key store should contain the server certificate. This is mandatory - the client will not be able to connect
   to the server over SSL if the server does not have a certificate.
   
   The key store is configured on the server using the [[io.vertx.ceylon.core::NetworkBase.keyStorePath]] and
   [[io.vertx.ceylon.core::NetworkBase.keyStorePassword]] methods.
   
   The trust store is optional and contains the certificates of any clients it should trust. This is only used if client
   authentication is required.
   
   To configure a server to use server certificates only:

   ~~~
   value server = vertx.createNetServer();
   server.ssl = true;
   server.keyStorePath = "/path/to/your/keystore/server-keystore.jks";
   server.keyStorePassword = "password";
   ~~~
   
   Making sure that `server-keystore.jks` contains the server certificate.
   
   To configure a server to also require client certificates:
   
   ~~~
   value server = vertx.createNetServer();
   server.ssl = true;
   server.keyStorePath = "/path/to/your/keystore/server-keystore.jks";
   server.keyStorePassword = "password";
   server.trustStorePath = "/path/to/your/keystore/server-truststore.jks";
   server.trustStorePassword = "password";
   server.clientAuthRequired = true;
   ~~~
   
   Making sure that `server-truststore.jks` contains the certificates of any clients who the server trusts.
   
   If `clientAuthRequired` is set to `true and the client cannot provide a certificate, or it provides a certificate that the server does not trust then the connection attempt will not succeed.
   
   ## SSL Clients
   
   Net Clients can also be easily configured to use SSL. They have the exact same API when using SSL as when using standard sockets.
   
   To enable SSL on a [[NetClient]] the attribute [[io.vertx.ceylon.core::NetworkBase.ssl]] is set to `true`.
   
   If the [[io.vertx.ceylon.core::ClientBase.trustAll]] is invoked on the client, then the client will trust all server
   certificates. The connection will still be encrypted but this mode is vulnerable to 'man in the middle' 
   ttacks. I.e. you can't be sure who you are connecting to. Use this with caution. Default value is `false`.
   
   If [[io.vertx.ceylon.core::ClientBase.trustAll]] has not been set to `true` then a client trust store must be configured and
   should contain the certificates of the servers that the client trusts.
   
   The client trust store is just a standard Java key store, the same as the key stores on the server side. The client
   trust store location is set by using the attribute [[io.vertx.ceylon.core::NetworkBase.trustStorePath]] on the [[NetClient]]. If a server presents a certificate
   during connection which is not in the client trust store, the connection attempt will not succeed.
   
   If the server requires client authentication then the client must present its own certificate to the server
   when connecting. This certificate should reside in the client key store. Again it's just a regular Java key store.
   The client keystore location is set by using the [[io.vertx.ceylon.core::NetworkBase.keyStorePath]] attribute on the [[NetClient]].
   
   To configure a client to trust all server certificates (dangerous):
   
   ~~~
   value client = vertx.createNetClient();
   client.ssl = true;
   client.trustAll = true;
   ~~~
   
   To configure a client to only trust those certificates it has in its trust store:

   ~~~
   value client = vertx.createNetClient();
   client.ssl = true;
   client.trustStorePath = "/path/to/your/client/truststore/client-truststore.jks";
   client.trustStorePassword = "password";
   ~~~
   
   To configure a client to only trust those certificates it has in its trust store, and also to supply a client certificate:

   ~~~
   value client = vertx.createNetClient();
   client.ssl = true;
   client.trustStorePath = "/path/to/your/client/truststore/client-truststore.jks";
   client.trustStorePassword = "password";
   client.clientAuthRequired = true;
   client.keyStorePath = "/path/to/keystore/holding/client/cert/client-keystore.jks";
   client.keyStorePassword = "password";
   ~~~
   
   """
shared package io.vertx.ceylon.core.net;
