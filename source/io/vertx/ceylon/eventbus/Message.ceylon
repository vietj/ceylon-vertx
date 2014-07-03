import ceylon.json { JSonArray=Array, JSonObject=Object }
import org.vertx.java.core.eventbus { Message_=Message }
import io.vertx.ceylon.util { fromObject, fromArray }
import org.vertx.java.core { Handler_=Handler }
import ceylon.promise { Promise }
import java.lang { Double_ = Double, Long_ = Long, Boolean_ = Boolean, ByteArray }

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

"Represents a message on the event bus."
by("Julien Viet")
shared class Message<T = Anything>(
        "The wrapped message"
        Message_<Object> delegate,
		"The body of the message"
        shared T body,
		"The body of the message"
        shared String? replyAddress) {

    "Reply to this message. If the message was sent specifying a reply handler, that handler will be
     called when it has received a reply. If the message wasn't sent specifying a receipt handler
     this method does nothing."
    shared Promise<Message<M>> reply<M = Nothing>(Payload body) given M of String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray {
        
        //
        Handler_<Message_<Object>>? replyHandler;
        Promise<Message<M>> promise;
        if (`M` == `Nothing`) {
            replyHandler = null;
            promise = promiseOfNothing;
        } else {
            MessageAdapter<M> adapter = MessageAdapter<M>();
            replyHandler = adapter;
            promise = adapter.deferred.promise;
        }

        //
        switch(body)
        case (is Float) { delegate.reply(Double_(body), replyHandler); }
        case (is Integer) { delegate.reply(Long_(body), replyHandler); }
        case (is Boolean) { delegate.reply(Boolean_(body), replyHandler); }
        case (is String) { delegate.reply(body, replyHandler); }
        case (is JSonObject) { delegate.reply(fromObject(body), replyHandler); }
        case (is JSonArray) { delegate.reply(fromArray(body), replyHandler); }
        case (is ByteArray) { delegate.reply(body, replyHandler); }
        
        //
        return promise;
    }
}