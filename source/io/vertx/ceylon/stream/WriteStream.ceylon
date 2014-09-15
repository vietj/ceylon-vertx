import org.vertx.java.core.buffer { Buffer }
import org.vertx.java.core.streams { WriteStream_=WriteStream }
import org.vertx.java.core { Handler_=Handler }
import java.lang { Void_=Void }
import io.vertx.ceylon.util { functionalHandler }

"""Represents a stream of data that can be written to.
   
   Any class that implements this interface can be used by a [[Pump]] to pump data from a [[ReadStream]] to it."""
by("Julien Viet")
shared class WriteStream(shared WriteStream_<out Object> delegate) {
    
    """Write some data to the stream. The data is put on an internal write queue, and the write actually happens
       asynchronously. To avoid running out of memory by putting too much on the write queue,
       check the [[WriteStream.writeQueueFull]] method before writing. This is done automatically if using a [[Pump]]."""
    shared void write(Buffer data) => delegate.write(data);
    
    """Set the maximum size of the write queue to `maxSize`. You will still be able to write to the stream even
       if there is more than `maxSize` bytes in the write queue. This is used as an indicator by classes such as
       [[Pump]] to provide flow control."""
    shared void setWriteQueueMaxSize(Integer maxSize) => delegate.setWriteQueueMaxSize(maxSize);
    
    "This will return `true` if there are more bytes in the write queue than the value set using  [[WriteStream.setWriteQueueMaxSize]]"
    shared void writeQueueFull() => delegate.writeQueueFull();
    
    """Set a drain handler on the stream. If the write queue is full, then the handler will be called when the write
       queue has been reduced to maxSize / 2. See [[Pump]] for an example of this being used."""
    shared void drainHandler(void onDrain()) {
        object drainHandler satisfies Handler_<Void_> {
            shared actual void handle(Void_ v) {
                onDrain();
            }
        }
        delegate.drainHandler(drainHandler);
    }

    "Set an exception handler."
    shared void exceptionHandler(void onException(Throwable t)) {
      delegate.exceptionHandler(functionalHandler(onException));
    }
}