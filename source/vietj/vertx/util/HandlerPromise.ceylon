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

import org.vertx.java.core { Handler_=Handler, AsyncResult_=AsyncResult }
import vietj.promises { Deferred, Promise }

by("Julien Viet")
shared class HandlerPromise<Value, Result>(Value(Result) transform)
        satisfies Handler_<AsyncResult_<Result>>  {

    Deferred<Value> deferred = Deferred<Value>();
    shared Promise<Value> promise = deferred.promise;

    shared actual void handle(AsyncResult_<Result> asyncResult) {
        if (asyncResult.succeeded()) {
            value result = asyncResult.result();
            try {
                value val = transform(result);
                deferred.resolve(val);
            } catch(Exception e) {
                deferred.reject(e);
            }
        } else {
            value cause = asyncResult.cause();
            deferred.reject(cause);
        }
    }
}