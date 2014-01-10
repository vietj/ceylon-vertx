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
import ceylon.promises { Promise, Deferred, Future }
import ceylon.test { ... }

import ceylon.net.uri { Uri, parseUri=parse }
import ceylon.net.http.client { Request, Response }
import test.io.vertx.ceylon.http.server { ... }
import test.io.vertx.ceylon.http.client { ... }
import test.io.vertx.ceylon.eventbus { ... }

shared T assertResolve<T>(Promise<T>|Deferred<T> obj) {
    Future<T> future;
    switch (obj)
    case (is Promise<T>) { future = obj.future; }
    case (is Deferred<T>) { future = obj.promise.future; }
    T|Exception r = future.get(20000);
    if (is T r) {
        return r;
    } else if (is Exception r) {
        throw r;
    } else {
        throw Exception("Was not expecting this");
    }
}

shared Response assertRequest(String uri, {<String->{String*}>*} headers = {}) {
    Uri tmp = parseUri(uri);
    Request req = Request(tmp);
    for (header in headers) {
        req.setHeader(header.key, *header.item);
    }
    return req.execute();
}

by("Julien Viet")
void run() {
    value runner = createTestRunner([`module test.io.vertx.ceylon`], [SimpleLoggingListener()]);
    value result = runner.run();
    print(result);
}