import org.vertx.java.core {
  TCPSupport_=TCPSupport,
  SSLSupport_=SSLSupport
}
shared class NetworkBase(TCPSupport_<out Object> tcpBase, SSLSupport_<out Object> sslBase) {
  
  "The send buffer size"
  shared Integer sendBufferSize => tcpBase.sendBufferSize;
  
  "Set the send buffer size for connections created by this instance in bytes."
  assign sendBufferSize => tcpBase.setSendBufferSize(sendBufferSize);
  
  "The value of reuse address"
  shared Boolean reuseAddress => tcpBase.reuseAddress;
  
  "Set the reuseAddress setting for connections created by this instance."
  assign reuseAddress => tcpBase.setReuseAddress(reuseAddress);
  
  "the value of traffic class"
  shared Integer trafficClass => tcpBase.trafficClass;
  
  "Set the trafficClass setting for connections created by this instance."
  assign trafficClass => tcpBase.setTrafficClass(trafficClass);
  
  "The receive buffer size"
  shared Integer receiveBufferSize => tcpBase.receiveBufferSize;
  
  "Set the receive buffer size for connections created by this instance in bytes."
  assign receiveBufferSize => tcpBase.setReceiveBufferSize(receiveBufferSize);
  
  """Is SSL enabled"""
  shared Boolean ssl => sslBase.ssl;
  
  """If `true`, this signifies that any connections will be SSL connections."""
  assign ssl => sslBase.setSSL(ssl);
  
  "Get the key store path"
  shared String keyStorePath => sslBase.keyStorePath;
  
  "Set the path to the SSL key store. This method should only be used in SSL mode, i.e. after
   [[sslBase]] has been set to {@code true}.
   The SSL key store is a standard Java Key Store, and will contain the client certificate.
   Client certificates are only required if the server requests client authentication."
  assign keyStorePath => sslBase.setKeyStorePath(keyStorePath);
  
  "Get the key store password"
  shared String keyStorePassword => sslBase.keyStorePassword;
  
  "Set the password for the SSL key store. This method should only be used in SSL mode, i.e. after
   [[sslBase]] has been set to `true`."
  assign keyStorePassword => sslBase.setKeyStorePassword(keyStorePassword);
  
  "Get the trust store path"
  shared String trustStorePath => sslBase.trustStorePath;
  
  "Set the path to the SSL trust store. This method should only be used in SSL mode, i.e. after
   [[sslBase]] has been set to `true`. The trust store is a standard Java Key Store, and should contain
   the certificates of any servers that the client trusts."
  assign trustStorePath => sslBase.setTrustStorePath(trustStorePath);
  
  "Get trust store password"
  shared String trustStorePassword => sslBase.trustStorePassword;
  
  "Set the password for the SSL trust store. This method should only be used in SSL mode, i.e. after
   [[sslBase]] has been set to `true`."
  assign trustStorePassword => sslBase.setTrustStorePassword(trustStorePassword);
}