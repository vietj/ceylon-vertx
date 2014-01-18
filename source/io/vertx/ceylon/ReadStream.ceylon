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

import org.vertx.java.core.buffer { Buffer }
import org.vertx.java.core.streams { ReadStream_=ReadStream }
import org.vertx.java.core { Handler_=Handler }
import java.lang { Void_=Void }
import io.vertx.ceylon.interop { Utils { rawReadStream } }

"Create a read stream"
by("Julien Viet")
shared ReadStream readStream<T>(ReadStream_<T> stream) given T satisfies Object {
    return ReadStream(rawReadStream(stream));
}

"""Represents a stream of data that can be read from.
   
   Any class that implements this interface can be used by a [[Pump]] to pump data from it to a [[WriteStream]]."""
by("Julien Viet")
shared class ReadStream(shared ReadStream_<Object> delegate) {
    
    "Set a data handler. As data is read, the handler will be called with the data."
    shared void dataHandler(void handleData(Buffer buffer)) {
        object dataHandler satisfies Handler_<Buffer> {
            shared actual void handle(Buffer buffer) {
                handleData(buffer);
            }
        }
        delegate.dataHandler(dataHandler);
    }
    
    "Set an end handler. Once the stream has ended, and there is no more data to be read, this handler will be called."
    shared void endHandler(void handleEnd()) {
        object endHandler satisfies Handler_<Void_> {
            shared actual void handle(Void_ v) {
                handleEnd();
            }
        }
        delegate.endHandler(endHandler);
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