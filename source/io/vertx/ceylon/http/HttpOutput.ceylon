import io.vertx.ceylon { writeStream, WriteStream }
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

"Provides access for writing the headers and  content of an
 [[HttpClientRequest]] or an [[HttpServerResponse]]."
by("Julien Viet")
shared abstract class HttpOutput<O>() given O satisfies HttpOutput<O> {

    "Set the response headers."
    shared formal O headers({<String-><String|{String+}>>*} headers);

    "Write a chunk to the output body."
    shared formal O write(
        """The data chunk to write:
           - when the argument is a `String` the `UTF-8` encoding is used
           - when the argument is a `[String,String]`, the first value is the chunk and the second is the encoding"""
        String|[String,String] chunk);
    
    "The write stream of this request"
    shared formal WriteStream stream;


    "Ends the response. If no data has been written to the response body,
     the actual response won't get written until this method gets called.
     Once the response has ended, it cannot be used any more."
    shared formal O end(
        """The optional data chunk to write as the response content:
           - when the argument is a `String` the `UTF-8` encoding is used
           - when the argument is a `[String,String]`, the first value is the chunk and the second is the encoding"""
        <String|[String,String]>? chunk = null);

    "Set the content type of the response."
    shared default O contentType(String mimeType, String charset = "UTF-8") {
        return headers { "Content-Type" -> "``mimeType``; charset=``charset``" };
    }
}