import org.vertx.java.core.http { HttpClient_=HttpClient  }

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