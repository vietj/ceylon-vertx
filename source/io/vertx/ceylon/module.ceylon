"""# Vert.x for Ceylon
   
   Vert.x is a lightweight, high performance application platform for the JVM that's designed for modern mobile, web,
   and enterprise applications.
   
   The original [Vert.x documentation](http://vertx.io/docs.html) explains how to use Vert.x. This Ceylon module is a port
   of the Vert.x API to Ceylon, with this API you can:
   
   - Embed Vert.x in a Ceylon application
   - Use the Vert.x API
   - Implement write verticles in Ceylon to deploy in Vert.x using the [Vert.x Ceylon module](https://github.com/vietj/vertx-ceylon)
     for running Ceylon verticles
   
   # Reference

   ## Writing Verticles
   
   *Todo*
   
   ## Deploying and Undeploying Verticles Programmatically
   
   *Todo*

   ## Scaling your application
   
   A verticle instance is almost always single threaded (the only exception is multi-threaded worker verticles which are
   an advanced feature), this means a single instance can at most utilise one core of your server.

   In order to scale across cores you need to deploy more verticle instances. The exact numbers depend on your application
   - how many verticles there are and of what type.
   
   You can deploy more verticle instances programmatically or on the command line when deploying your module using the
   -instances command line option.
   
   ## The Event Bus
   
   See [[package io.vertx.ceylon.eventbus]].
   
   ## Shared Data
   
   See [[package io.vertx.ceylon.shareddata]].
   
   ## Buffers
   
   Most data in Vert.x is shuffled around using instances of [[org.vertx.java.core.buffer::Buffer]]. We chose deliberately
   to use the Vert.x native type as it can easily used from Ceylon and a wrapper would complicate the bridge.
   
   A Buffer represents a sequence of zero or more bytes that can be written to or read from, and which expands
   automatically as necessary to accomodate any bytes written to it. You can perhaps think of a buffer as smart byte array.
   
   ### Creating Buffers
   
   Create a new empty buffer:
   
   ~~~
   value buff = Buffer();
   ~~~
   
   Create a buffer from a String. The String will be encoded in the buffer using UTF-8.
   
   ~~~
   value buff = Buffer("some-string");
   ~~~
   
   Create a buffer from a String: The String will be encoded using the specified encoding, e.g:

   ~~~
   value buff = Buffer("some-string", "UTF-16");
   ~~~
   
   Create a buffer from a byte[] (using [[java.lang::ByteArray]])
   
   ~~~
   ByteArray bytes = ...;
   value buff = Buffer(bytes);   
   ~~~
   
   Create a buffer with an initial size hint. If you know your buffer will have a certain amount of data written to it
   you can create the buffer and specify this size. This makes the buffer initially allocate that much memory and
   is more efficient than the buffer automatically resizing multiple times as data is written to it.
   
   Note that buffers created this way are empty. It does not create a buffer filled with zeros up to the specified size.
   
   ~~~
   value buff = Buffer(10000);
   ~~~
   
   ### Writing to a Buffer
   
   There are two ways to write to a buffer: appending, and random access. In either case buffers
   will always expand automatically to encompass the bytes. It's not possible to get an
   `IndexOutOfBoundsException` with a buffer.
   
   #### Appending to a Buffer
   
   To append to a buffer, you use the `appendXXX` methods. Append methods exist for appending other buffers,
   byte[], String and all primitive types.
   
   The return value of the appendXXX methods is the buffer itself, so these can be chained:
   
   ~~~
   value buff = Buffer();
   
   buff.appendInt(123).appendString("hello\n");
   ~~~
   
   #### Random access buffer writes
   
   You can also write into the buffer at a specific index, by using the `setXXX` methods. Set methods exist for other
   buffers, byte[], String and all primitive types. All the set methods take an index as the first argument - this
   represents the position in the buffer where to start writing the data.
   
   ~~~
   value buff = Buffer();
   
   buff.setInt(1000, 123);
   buff.setString(0, "hello");
   ~~~

   ### Reading from a Buffer
   
   Data is read from a buffer using the `getXXX` methods. Get methods exist for byte[], String and all primitive types.
   The first argument to these methods is an index in the buffer from where to get the data.
   
   ~~~
   Buffer buff = ...;
   Integer i = buff.getInt(0);
   ~~~

   ### Other buffer methods:

   - length(). To obtain the length of the buffer. The length of a buffer is the index of the byte in the buffer with the largest index + 1.
   - copy(). Copy the entire buffer
   
   ## JSON
   
   Whereas JavaScript has first class support for JSON, and Ruby has Hash literals which make representing JSON easy
   within code, things aren't so easy in Ceylon
   
   A JSON object is represented by instances of [[ceylon.json::Object]]. A JSON array is represented by instances of
   [[ceylon.json::Array]].
   
   A usage example would be using a Ceylon verticle to send or receive JSON messages from the event bus.
   
   ~~~
   value eb = vertx.eventBus();
   
   value obj = Object { "foo"->"wibble", "age"->1000 };
   eb.send("some-address", obj);
   
   // ....
   // And in a handler somewhere:
   
   shared void handle(Message<Object> message) {
     print("foo is ``message.body["foo"]``");
     print("age is ``message.body["age"]``");
   }
   ~~~

   ## Delayed and Periodic Tasks
   
   It's very common in Vert.x to want to perform an action after a delay, or periodically.
   
   In standard verticles you can't just make the thread sleep to introduce a delay, as that will block the event loop
   thread.
   
   Instead you use Vert.x timers. Timers can be _one-shot_ or _periodic_. We'll discuss both
   
   ### One-shot Timers
   
   A one shot timer calls an event handler after a certain delay, expressed in milliseconds.

   To set a timer to fire once you use the [[Vertx.setTimer]] method passing in the delay and a handler
   
   ~~~
   value timerId = vertx.setTimer(1000, (Integer timerId) => print("And one second later this is printed"));
   
   print("First this is printed");
   ~~~
   
   The return value is a unique timer id which can later be used to cancel the timer. The handler is also passed the timer id.
   
   ### Periodic Timers
   
   You can also set a timer to fire periodically by using the [[Vertx.setPeriodic]] method. There will be an initial
   delay equal to the period. The return value of [[Vertx.setPeriodic]] is a unique timer id
   (long). This can be later used if the timer needs to be cancelled. The argument passed into the timer
   event handler is also the unique timer id:

   ~~~
   value timerId = vertx.setTimer(1000, (Integer timerId) => print("And every second this is printed"));
   
   print("First this is printed");
   ~~~
   
   ### Cancelling timers
   
   To cancel a periodic timer, call the [[Vertx.cancelTimer]] method specifying the timer id. For example:

   ~~~
   value timerId = vertx.setTimer(1000, (Integer timerId) => print("Should not be printed"));
   
   // And immediately cancel it
   
   vertx.cancelTimer(timerID);
   ~~~
   
   Or you can cancel it from inside the event handler. The following example cancels the timer after it has fired 10 times.

   ~~~
   variable Integer count = 0;
   vertx.setTimer {
     delay = 1000;
     void handle(Integer timerId) {
       print("In event handler ``count``");
       if (++count == 10) {
         vertx.cancelTimer(timerId);
       }
     }
   };
   ~~~
   
   ## Writing TCP Servers and Clients
   
   See [[package io.vertx.ceylon.net]].

   ## Flow Control - Streams and Pumps
   
   Implemented for Http package, documentation uses a net server, so not yet translated.
   
   ## Writing HTTP Servers and Clients
   
   See [[package io.vertx.ceylon.http]].
   
   ## Routing HTTP requests with Pattern Matching
   
   See [[package io.vertx.ceylon.http]].
   
   ## WebSockets
   
   See [[package io.vertx.ceylon.http]].
   
   ## SockJS
   
   See [[package io.vertx.ceylon.sockjs]]
   
   ## SockJS - EventBus Bridge
   
   See [[package io.vertx.ceylon.sockjs]]
   
   ## File System
   
   See [[package io.vertx.ceylon.file]]
   
   """
by("Julien Viet")
license("ASL2")
module io.vertx.ceylon "0.4.0" {

    import io.netty "4.0.20.Final";
    import com.fasterxml.jackson.annotations "2.2.2";
    import com.fasterxml.jackson.core "2.2.2";
    import com.fasterxml.jackson.databind "2.2.2";
    shared import io.vertx.core "2.1.2";
    shared import io.vertx.platform "2.1.2";
    shared import java.base "7";
    shared import ceylon.promise "1.1.0";
    shared import ceylon.json "1.1.0";
    shared import ceylon.io "1.1.0";
    shared import ceylon.time "1.1.0";
    import ceylon.collection "1.1.0";

} 
