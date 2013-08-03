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
import org.vertx.java.core.http { HttpClient_=HttpClient  }

by "Julien Viet"
license "ASL2"
doc "An HTTP client that maintains a pool of connections to a specific host, at a specific port. The client supports
     pipelining of requests.
     
     If an instance is instantiated from an event loop then the handlers of the instance will always be called on that
     same event loop. If an instance is instantiated from some other arbitrary Java thread (i.e. when running embedded)
     then and event loop will be assigned to the instance and used when any of its handlers are called.
     
     Instances of HttpClient are thread-safe."
shared class HttpClient(HttpClient_ delegate) {
	
	doc "Returns the maximum number of connections in the pool"
	shared Integer maxPoolSize => delegate.maxPoolSize;
	
	doc "Set the maximum pool size. The client will maintain up to `maxConnections` HTTP connections in an internal pool"
	assign maxPoolSize => delegate.setMaxPoolSize(maxPoolSize);
	
	doc "The port"
	shared Integer port => delegate.port;
	
	doc "Set the port that the client will attempt to connect to the server on to `port`. The default value is `80`"
	assign port => delegate.setPort(port);
	
	doc "The host"
	shared String host => delegate.host;
	
	doc "Set the host that the client will attempt to connect to the server on to `host`. The default value is `localhost`"
	assign host => delegate.setHost(host);
	
	doc "Is the client keep alive?"
	shared Boolean keepAlive => delegate.keepAlive;
	
	doc "If `keepAlive` is `true` then, after the request has ended the connection will be returned to the pool
         where it can be used by another request. In this manner, many HTTP requests can be pipe-lined over an HTTP connection.
         Keep alive connections will not be closed until the `close()` method is invoked.
      
         If `keepAlive` is `false`}then a new connection will be created for each request and it won't ever go in the pool,
         the connection will closed after the response has been received. Even with no keep alive,
         the client will not allow more than `maxPoolSize` connections to be created at any one time."
	assign keepAlive => delegate.setKeepAlive(keepAlive);
	
	doc "true if this client will validate the remote server's certificate hostname against the requested host"
	shared Boolean verifyHost => delegate.verifyHost;
	
	doc "If `verifyHost` is `true`, then the client will try to validate the remote server's certificate
        hostname against the requested host. Should default to `true`. This method should only be used in SSL mode,
        i.e. after `ssl` has been set to `true`."
	assign verifyHost => delegate.setVerifyHost(verifyHost);
	
	doc "The connect timeout in milliseconds."
	shared Integer connectTimeout => delegate.connectTimeout;
	
	doc "Set the connect timeout in milliseconds."
	assign connectTimeout => delegate.setConnectTimeout(connectTimeout);
	
	doc "This method returns an [HttpClientRequest] instance which represents an HTTP request with the specified `uri`.
         The specific HTTP method (e.g. GET, POST, PUT etc) is specified using the parameter `method`.
      
         When an HTTP response is received from the server the promise `response` is resolved with the response."
	shared HttpClientRequest request(String method, String uri) {
		return HttpClientRequest(delegate, method, uri);
	}
	
}