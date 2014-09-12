import org.vertx.java.core { TCPSupport_=TCPSupport, ClientSSLSupport_=ClientSSLSupport }

shared class ClientBase(TCPSupport_<out Object> tcpClient, ClientSSLSupport_<out Object> sslClient) extends NetworkBase(tcpClient, sslClient) {
  
  "true if this client will trust all server certificates."
  shared Boolean trustAll => sslClient.trustAll;
  
  """If you want an SSL client to trust *all* server certificates rather than match them
     against those in its trust store, you can set this to true.
     Use this with caution as you may be exposed to "main in the middle" attacks"""
  assign trustAll => sslClient.setTrustAll(trustAll);
  
}