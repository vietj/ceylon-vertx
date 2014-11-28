import org.vertx.java.core.http {
  WebSocket_=WebSocket
}
import ceylon.promise {
  ExecutionContext
}

shared class WebSocket(ExecutionContext context, WebSocket_ delegate) extends WebSocketBase(context, delegate) {
}
