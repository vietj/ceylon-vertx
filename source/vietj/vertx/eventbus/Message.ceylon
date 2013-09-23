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
shared class Message<T>(
        T body_,
        String? replyAddress_,
        Anything(BodyType) doReply) {

    "The body of the message"
    shared T body = body_;

    "The body of the message"
    shared String? replyAddress = replyAddress_;

    "Reply to this message. If the message was sent specifying a reply handler, that handler will be
             called when it has received a reply. If the message wasn't sent specifying a receipt handler
             this method does nothing."
    shared void reply(BodyType body) {
        doReply(body);
    }

}