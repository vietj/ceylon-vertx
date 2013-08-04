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

import vietj.promises { Promise, Deferred }
import org.vertx.java.core.buffer { Buffer }
import org.vertx.java.core { Handler_=Handler }
import org.vertx.java.core.streams { ReadStream }
import ceylon.io.charset { Charset, getCharset }
import vietj.vertx.interop { ExceptionSupportAdapter { handle } }

by "Julien Viet"
license "ASL2"
doc "Provides access for reading the http headers and the body of an [[HttpServerRequest]] or an [[HttpClientResponse]]."
shared abstract class HttpInput() {
	
	variable [String?, Charset?]? _contentType = null;
	
	[String?, Charset?] contentType {
		if (exists tmp = _contentType) {
			return tmp;
		} else {
			String? mimeType;
			Charset? charset;
			if (exists contentType = headers["Content-Type"]) {
				if (exists pos = contentType.first.firstCharacterOccurrence(';')) {
					mimeType = contentType.first.segment(0, pos).trimmed;
					if (exists charsetPos = contentType.first.lastCharacterOccurrence('=')) {
						value name = contentType.first.segment(charsetPos + 1, contentType.first.size);
						charset = getCharset(name);
					} else {
						charset = null;
					}
				} else {
					mimeType = contentType.first.trimmed;
					charset = null;
				}
			} else {
				mimeType = null;
				charset = null;
			}
			value ret = [mimeType, charset];
			_contentType = ret;
			return ret;
		}
	}
	
	doc "The headers"
	shared formal Map<String,{String+}> headers;

	doc "The charset or null"
	shared default Charset? charset {
		return contentType[1];
	}
	
	doc "The mime type or null"
	shared default String? mimeType {
		return contentType[0];
	}

	doc "Parse the input body, the returned promise is resolved with the body."
	shared formal Promise<Body> parseBody<Body>(BodyType<Body> parser);
	
}

doc "Parse the body of an input"
Promise<Body> doParseBody<Body, T>(
	BodyType<Body> bodyType,
	Anything(Handler_<Buffer>) setBodyHandler,
	ReadStream<T> stream,
	Charset? charset) {
		
	//
	Deferred<Body> deferred = Deferred<Body>();
		
	//
	object valueHandler satisfies Handler_<Buffer> {
		shared actual void handle(Buffer e) {
			Body body = bodyType.parse(charset, e);
			deferred.resolve(body);
		}
	}

	// Set handlers and resume the paused handler
	setBodyHandler(valueHandler);
	handle(stream, deferred);
	stream.resume();
		
	//
	return deferred.promise;
}
