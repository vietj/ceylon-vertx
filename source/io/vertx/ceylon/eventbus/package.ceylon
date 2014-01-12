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

"""# The Event Bus
   
   The event bus is the nervous system of Vert.x.
   
   It allows verticles to communicate with each other irrespective of what language they are written in, and whether
   they're in the same Vert.x instance, or in a different Vert.x instance.
   
   It even allows client side JavaScript running in a browser to communicate on the same event bus. (More on that later).
   
   The event bus forms a distributed peer-to-peer messaging system spanning multiple server nodes and multiple browsers.
   
   The event bus API is incredibly simple. It basically involves registering handlers, unregistering handlers and
   sending and publishing messages.
   
   First some theory:  
   
   # The Theory
   
   ## Addressing
   
   Messages are sent on the event bus to an address.
   
   Vert.x doesn't bother with any fancy addressing schemes. In Vert.x an address is simply a string, any string is
   valid. However it is wise to use some kind of scheme, e.g. using periods to demarcate a namespace.
   
   Some examples of valid addresses are `europe.news.feed1`, `acme.games.pacman`, `sausages`, and `X`. 
   
   ## Handlers
   
   A handler is a thing that receives messages from the bus. You register a handler at an address.
   
   Many different handlers from the same or different verticles can be registered at the same address.
   A single handler can be registered by the verticle at many different addresses.
   
   ## Publish / subscribe messaging
   
   The event bus supports *publishing* messages. Messages are published to an address. Publishing means delivering
   the message to all handlers that are registered at that address. This is the familiar *publish/subscribe* messaging pattern.
   
   ## Point to point and Request-Response messaging
   
   The event bus supports *point to point* messaging. Messages are sent to an address. Vert.x will then route it to just
   one of the handlers registered at that address. If there is more than one handler registered at the address,
   one will be chosen using a non-strict round-robin algorithm.
   
   With point to point messaging, an optional reply handler can be specified when sending the message. When a message
   is received by a recipient, and has been handled, the recipient can optionally decide to reply to the message. If they
   do so that reply handler will be called.
   
   When the reply is received back at the sender, it too can be replied to. This can be repeated ad-infinitum, and
   allows a dialog to be set-up between two different verticles. This is a common messaging pattern called the Request-Response pattern.
   
   ## Transient
   
   *All messages in the event bus are transient, and in case of failure of all or parts of the event bus, there is a
   possibility messages will be lost. If your application cares about lost messages, you should code your handlers to be
   idempotent, and your senders to retry after recovery.*
   
   If you want to persist your messages you can use a persistent work queue module for that.
   
   ## Types of messages
   
   Messages that you send on the event bus can be as simple as a string, a number or a boolean. You can also send Vert.x buffers or JSON messages.
   
   It's highly recommended you use JSON messages to communicate between verticles. JSON is easy to create and parse in all the
   languages that Vert.x supports.
   
   # Event Bus API
   
   Let's jump into the API.
   
   ## Registering and Unregistering Handlers
   
   To set a message handler on the address `test.address`, you do something like the following:
   
   ~~~
   value eb = vertx.eventBus();
   function myHandler(Message message) => print("I received a message ``message.body``");
   eb.registerHandler("test.address", myHandler);
   ~~~
   
   It's as simple as that. The handler will then receive any messages sent to that address.
   
   The class [[Message]] is a generic type and specific Message types include:
   - `Message<String>` : mapped to Ceylon `String`
   - `Message<Boolean>` : mapped to Ceylon `Boolean`
   - `Message<byte[]>` : mapped to `java.lang.ByteArray` virtual type
   - `Message<Double>` : mapped to Ceylon `Float`
   - `Message<JsonObject>` : mapped to `ceylon.json.Object`
   - `Message<JsonArray>` : mapped to `ceylon.json.Array`
   - `Message<Long>` : mapped to Ceylon `Integer`
   - `Message<Buffer>` : not supported at the moment
   - `Message<Byte>` : not supported at the moment
   - `Message<Character>` : not supported at the moment
   - `Message<Float>` : not supported at the moment
   - `Message<Integer>` : not supported at the moment
   - `Message<Short>` : not supported at the moment
   
   If you know you'll always be receiving messages of a particular type you can use the specific type in your handler, e.g:
   
   ~~~
   void myHandler(Message<String> message) {
      String body = message.body;
   }
   ~~~
   
   The return value of [[EventBus.registerHandler]] is a [[io.vertx.ceylon::Registration]] object that allows to unregister an handler:
   
   ~~~
   value registration = eb.registerHandler("test.address", myHandler);
   registration.cancel();
   ~~~
   
   When you register a handler on an address and you're in a cluster it can take some time for the knowledge of that
   new handler to be propagated across the entire cluster. If you want to be notified you can use the [[io.vertx.ceylon::Registration.completed]]
   `Promise` object. This promise will then be resolved once the information has reached all nodes of the cluster.

   ~~~
   value registration = eb.registerHandler("test.address", myHandler);
   registration.completed.then_(
    (Registration registration) => print("The handler has been registered across the cluster",
    (Exception failure) => print("The handler has not been registered across the cluster: ``failure.message`"
   );
   ~~~

   If you want your handler to live for the full lifetime of your verticle there is no need to unregister it explicitly - Vert.x will
   automatically unregister any handlers when the verticle is stopped.
   
   ## Publishing messages
   
   Publishing a message is also trivially easy. Just publish it specifying the address, for example:
   
   ~~~
   eb.publish("test.address", "hello world");
   ~~~
   
   That message will then be delivered to all handlers registered against the address `test.address`.
   
   ## Sending messages
   
   Sending a message will result in only one handler registered at the address receiving the message. This is the point to point messaging pattern.
   The handler is chosen in a non strict round-robin fashion.
   
   ~~~
   eb.send("test.address", "hello world");
   ~~~
   
   ## Replying to messages
   
   Sometimes after you send a message you want to receive a reply from the recipient. This is known as the *request-response* pattern.
   
   To do this you send a message, and specify a specify a return type that you expected: the various methods for sending messages
   return a `Promise<Message<M>>` that is resolved when the reply is received, when no type is not specified it falls down to
   `Nothing`. When the receiver receives the message they can reply to it by calling the reply method on the message.
   When this method is invoked it causes a reply to be sent back to the sender where the reply Promise is resolved. An example will make this clear:
   
   The receiver:
   ~~~
   void myHandler(Message<String> message) {
     print("I received a message ``message.body``");

     // Do some stuff
     
     // Now reply to it
     message.reply("This is a reply");
   }
   ~~~
   
   The sender:
   ~~~
   value reply = eb.send<String>("test.address", "This is a message");
   reply.then_((Message<String> message) => println("I received a reply ``message.body``"));
   ~~~
   
   It is legal also to send an empty reply or a null reply (*todo*).
   
   The replies themselves can also be replied to so you can create a dialog between two different verticles consisting of multiple rounds.
   
   ### Specifying timeouts for replies
   
   *Not yet in 2.0*
   
   ### Getting notified of reply failures
   
   *Not yet in 2.0*
   
   ## Message types
   
   The message you send can be any of the following types:
   
   * boolean
   * byte[]
   * double
   * long
   * java.lang.String
   * org.vertx.java.core.json.JsonObject
   * org.vertx.java.core.json.JsonArray
   
   The following types are not supported at the moment
   
   * short
   * float
   * integer
   * org.vertx.java.core.buffer.Buffer
   * byte
   * character
   
   Vert.x buffers and JSON objects and arrays are copied before delivery if they are delivered in the same JVM, so different verticles
   can't access the exact same object instance which could lead to race conditions.
   
   Here are some more examples:
   
   Send some numbers:
   
   ~~~
   eb.send("test.address", 1234);
   eb.send("test.address", 3.14159);
   ~~~
   
   Send a boolean:
   
   ~~~
   eb.send("test.address", true);
   ~~~
   
   Send a JSON object:
   
   ~~~
   value obj = new Object { "foo"->"wibble" };
   eb.send("test.address", obj);
   ~~~
   
   Null messages can also be sent (not supported at the moment):
   
   ~~~
   eb.send("test.address", null);
   ~~~
   
   It's a good convention to have your verticles communicating using JSON - this is because JSON is easy to generate and parse
   for all the languages that Vert.x supports.
   
   # Distributed event bus
   
   To make each Vert.x instance on your network participate on the same event bus, start each Vert.x instance with the
   -cluster command line switch.
   
   See the chapter in the main manual on [running Vert.x](http://vertx.io/core_manual_java.html) for more information on this.
   
   Once you've done that, any Vert.x instances started in cluster mode will merge to form a distributed event bus.
   """
by("Julien Viet")
shared package io.vertx.ceylon.eventbus;
