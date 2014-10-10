import org.vertx.java.core.streams {
  Pump_=Pump
}

"""Pumps data from a [[ReadStream]] to a [[WriteStream]] and performs flow control where necessary to
   prevent the write stream buffer from getting overfull.
   
   Instances of this class read bytes from a [[ReadStream]] and write them to a [[WriteStream]]. If data
   can be read faster than it can be written this could result in the write queue of the [[WriteStream]] growing
   without bound, eventually causing it to exhaust all available RAM.
   
   To prevent this, after each write, instances of this class check whether the write queue of the [[WriteStream]]
   is full, and if so, the {@link ReadStream} is paused, and a [[WriteStream.drainHandler]] is set on the
   [[WriteStream]]. When the [[WriteStream]] has processed half of its backlog, the [[WriteStream.drainHandler]] will be
   called, which results in the pump resuming the [[ReadStream]].
   
   This class can be used to pump from any [[ReadStream]] to any [[WriteStream]],
   e.g. from an [[io.vertx.ceylon.core.http::HttpServerRequest]] to an {@link org.vertx.java.core.file.AsyncFile} (todo),
   or from {@link org.vertx.java.core.net.NetSocket} (todo) to a {@link org.vertx.java.core.http.WebSocket} (todo).
   
   Instances of this class are not thread-safe.
"""
shared class Pump(ReadStream rs, WriteStream ws, Integer? maxSize = null) {
  
  Pump_ delegate;
  if (exists maxSize) {
    delegate = Pump_.createPump(rs.delegate, ws.delegate, maxSize);
  } else {
    delegate = Pump_.createPump(rs.delegate, ws.delegate);
  }
  
  "Set the write queue max size to `maxSize"
  shared Pump setWriteQueueMaxSize(Integer maxSize) {
    delegate.setWriteQueueMaxSize(maxSize);
    return this;
  }
  
  "Start the Pump. The Pump can be started and stopped multiple times."
  shared Pump start() {
    delegate.start();
    return this;
  }
  
  "Stop the Pump. The Pump can be started and stopped multiple times."
  shared Pump stop() {
    delegate.stop();
    return this;
  }
  
  "Return the total number of bytes pumped by this pump."
  shared Integer bytesPumped => delegate.bytesPumped();
}
