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
   
   See [io.vertx.ceylon.eventbus](eventbus/index.html).
   
   ## Shared Data
   
   *Not yet implemented*
   
   ## Buffers
   
   *Not yet implemented*
   
   ## JSON
   
   *Todo*
   
   ## Delayed and Periodic Tasks
   
   * Not yet implemented*
   
   ## Writing TCP Servers and Clients
   
   * Not yet implemented *
   
   ## User Datagram Protocol (UDP)
   
   *Not yet in 2.0*
   
   ## Flow Control - Streams and Pumps
   
   Implemented for Http package, documentation uses a net server, so not yet translated.
   
   ## Writing HTTP Servers and Clients
   
   *Todo*
   
   ## Routing HTTP requests with Pattern Matching
   
   *Todo*
   
   ## WebSockets
   
   *Not yet implemented*
   
   ## SockJS
   
   *Not yet implemented*
   
   ## SockJS - EventBus Bridge
   
   *Not yet implemented*
   
   ## File System
   
   *Not yet implemented*
   
   ## DNS Client
   
   *Not yet in 2.0*
   
   """
by("Julien Viet")
license("ASL2")
module io.vertx.ceylon "0.3.9" {

    import io.netty "4.0.10.Final";
    import com.fasterxml.jackson.annotations "2.2.2";
    import com.fasterxml.jackson.core "2.2.2";
    import com.fasterxml.jackson.databind "2.2.2";
    shared import io.vertx.core "2.0.2-final";
    shared import io.vertx.platform "2.0.2-final";
    shared import java.base "7";
    shared import ceylon.promises "0.5.0";
    shared import ceylon.net "1.0.0";
    shared import ceylon.json "1.0.0";
    import ceylon.io "1.0.0";
    import ceylon.collection "1.0.0";

} 
