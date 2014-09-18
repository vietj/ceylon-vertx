"""# Shared Data
   
   Sometimes it makes sense to allow different verticles instances to share data in a safe way. Vert.x allows simple
   [[SharedMap]] (like a [[java.util.concurrent::ConcurrentMap]] and [[SharedSet]] data structures to be shared between
   verticles.
   
   There is a caveat: To prevent issues due to mutable data, Vert.x only allows simple immutable types such as 
   number, boolean and string or Buffer to be used in shared data. With a Buffer, it is automatically copied
   when retrieved from the shared data, so different verticle instances never see the same object instance.
   
   Currently data can only be shared between verticles in the same Vert.x instance. In later versions of Vert.x
   we aim to extend this to allow data to be shared by all Vert.x instances in the cluster.
   
   ## Shared Maps
   
   To use a shared map to share data between verticles first we get a reference to the map, and then use it like
   any other instance of [[SharedMap]]
   
   ~~~
   SharedMap<String, Integer> map = vertx.sharedData.getMap("demo.mymap");

   map.put("some-key", 123);
   ~~~
   
   And then, in a different verticle you can access it:
   
   ~~~
   SharedMap<String, Integer> map = vertx.sharedData.getMap("demo.mymap");
   
   // etc
   ~~~
   
   ## Shared Sets
   
   To use a shared set to share data between verticles first we get a reference to the set.
   
   ~~~
   SharedSet<String> set = vertx.sharedData.getSet("demo.myset");
   
   set.add("some-value");
   ~~~
   
   And then, in a different verticle:

   ~~~
   SharedSet<String> set = vertx.sharedData.getSet("demo.myset");
   
   // etc
   ~~~
   """
shared package io.vertx.ceylon.core.shareddata;
