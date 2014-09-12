import org.vertx.java.core.buffer { Buffer }
import org.vertx.java.core.streams { ReadStream_=ReadStream }
import io.vertx.ceylon.interop { Utils { rawReadStream } }
import io.vertx.ceylon.util { functionalHandler,
  VoidNoArgHandler }

"Create a read stream"
by("Julien Viet")
shared ReadStream wrapReadStream<T>(ReadStream_<out T> stream) given T satisfies Object {
    return ReadStream(rawReadStream(stream));
}

"""Represents a stream of data that can be read from.
   
   Any class that implements this interface can be used by a [[Pump]] to pump data from it to a [[WriteStream]]."""
by("Julien Viet")
shared class ReadStream(shared ReadStream_<Object> delegate) {
    
    "Set a data handler. As data is read, the handler will be called with the data."
    shared void dataHandler(void onData(Buffer buffer)) {
        delegate.dataHandler(functionalHandler(onData));
    }
    
    "Set an exception handler."
    shared void exceptionHandler(void onException(Throwable t)) {
      delegate.exceptionHandler(functionalHandler(onException));
    }
    
    "Set an end handler. Once the stream has ended, and there is no more data to be read, this handler will be called."
    shared void endHandler(void onEnd()) {
        value adapter = VoidNoArgHandler(onEnd);
        delegate.endHandler(adapter);
    }
    
    "Pause the `ReadStream`. While the stream is paused, no data will be sent to the `dataHandler`"
    shared void pause() => delegate.pause();

    "Resume reading. If the `ReadStream` has been paused, reading will recommence on it."
    shared void resume() => delegate.resume();
    
    "Create a new [[Pump]] with this `ReadStream` and the given[[WriteStream]] and `writeQueueMaxSize`"
    shared Pump pump(WriteStream to, Integer? writeQueueMaxSize = null) {
        return Pump(this, to, writeQueueMaxSize);
    }
}