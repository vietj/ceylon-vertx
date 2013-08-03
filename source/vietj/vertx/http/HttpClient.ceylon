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
shared class HttpClient(HttpClient_ delegate) {
	
	shared Integer maxPoolSize => delegate.maxPoolSize;
	assign maxPoolSize => delegate.setMaxPoolSize(maxPoolSize);
	shared Integer port => delegate.port;
	assign port => delegate.setPort(port);
	shared String host => delegate.host;
	assign host => delegate.setHost(host);
	shared Boolean keepAlive => delegate.keepAlive;
	assign keepAlive => delegate.setKeepAlive(keepAlive);
	shared Boolean verifyHost => delegate.verifyHost;
	assign verifyHost => delegate.setVerifyHost(verifyHost);
	shared Integer connectTimeout => delegate.connectTimeout;
	assign connectTimeout => delegate.setConnectTimeout(connectTimeout);
	
	shared HttpClientRequest request(String method, String uri) {
		return HttpClientRequest(delegate, method, uri);
	}
	
}