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

import io.vertx.ceylon.util { HandlerPromise }
import org.vertx.java.core { Handler_=Handler }
import ceylon.json { JSonArray=Array, JSonObject=Object }
import ceylon.promises { Promise }
import io.vertx.ceylon { Registration }
import java.lang { Void_=Void, ByteArray }
import org.vertx.java.core.eventbus { Message_=Message, EventBus_=EventBus }
import io.vertx.ceylon.interop { EventBusAdapter { registerHandler_=registerHandler, unregisterHandler_=unregisterHandler } }

by("Julien Viet")
class HandlerRegistration<M>(EventBus_ delegate, String address, Anything(Message<M>) handler)
        extends AbstractMessageAdapter<M>()
        satisfies Registration & Handler_<Message_<Object>>
        given M of String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray {
    
    value resultHandler = HandlerPromise<Null, Void_>((Void_ s) => null);
    shared actual Promise<Null> completed = resultHandler.promise;
    
    shared actual Promise<Null> cancel() {
        value resultHandler = HandlerPromise<Null, Void_>((Void_ s) => null);
        unregisterHandler_(delegate, address, this, resultHandler);
        return resultHandler.promise;
    }
    
    shared void register() {
        registerHandler_(delegate, address, this, resultHandler);
    }
    
    shared actual void dispatch(Message<M> message) {
        handler(message);
    }
    
    shared actual void reject(Object body) {
        // ????
    }
}
