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

"Vertx API for Ceylon"
by("Julien Viet")
license("ASL2")
module vietj.vertx '0.2.0' {

    import io.netty '4.0.2.Final';
    import com.fasterxml.jackson.annotations '2.2.2';
    import com.fasterxml.jackson.core '2.2.2';
    import com.fasterxml.jackson.databind '2.2.2';
    shared import io.vertx.core '2.0.0-final';
    import java.base '7';
    shared import vietj.promises '0.4.0';
    shared import ceylon.net '0.6';
    shared import ceylon.json '0.6';
    import ceylon.io '0.6';
    import ceylon.collection '0.6';

} 
