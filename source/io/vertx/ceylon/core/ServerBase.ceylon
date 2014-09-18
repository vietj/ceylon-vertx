import org.vertx.java.core { ServerSSLSupport_=ServerSSLSupport, ServerTCPSupport_=ServerTCPSupport }

shared class ServerBase(ServerTCPSupport_<out Object> tcpServer, ServerSSLSupport_<out Object> sslServer) extends NetworkBase(tcpServer, sslServer) {
  
  "true if Nagle's algorithm is disable."
  shared Boolean tcpNoDelay => tcpServer.tcpNoDelay;
  
  "If [[tcpNoDelay]] is set to `true` then [Nagle's algorithm](http://en.wikipedia.org/wiki/Nagle's_algorithm)
   will turned *off*> for the TCP connections created by this instance."
  assign tcpNoDelay => tcpServer.setTCPNoDelay(tcpNoDelay);
  
  "true if TCP keep alive is enabled"
  shared Boolean tcpKeepAlive => tcpServer.tcpKeepAlive;
  
  "Set the TCP keepAlive setting for connections created by this instance."
  assign tcpKeepAlive => tcpServer.setTCPKeepAlive(tcpKeepAlive);

  "the value of TCP so linger"
  shared Integer soLinger => tcpServer.soLinger;
  
  "Set the TCP soLinger setting for connections created by this instance.
    Using a negative value will disable soLinger."
  assign soLinger => tcpServer.setSoLinger(soLinger);

  "if pooled buffers are used"
  shared Boolean usePooledBuffers => tcpServer.usePooledBuffers;
  
  "Set if vertx should use pooled buffers for performance reasons. Doing so will give the best throughput but
   may need a bit higher memory footprint."
  assign usePooledBuffers => tcpServer.setUsePooledBuffers(usePooledBuffers);

  "The accept backlog"
  shared Integer acceptBacklog => tcpServer.acceptBacklog;
  
  "Set the accept backlog"
  assign acceptBacklog => tcpServer.setAcceptBacklog(acceptBacklog);
  
  "Is client auth required"
  shared Boolean clientAuthRequired => sslServer.clientAuthRequired;
  
  """Set to true if you want the server to request client authentication from any connecting clients. This
     is an extra level of security in SSL, and requires clients to provide client certificates.
     Those certificates must be added to the server trust store.
     """
  assign clientAuthRequired => sslServer.setClientAuthRequired(clientAuthRequired);
  
}