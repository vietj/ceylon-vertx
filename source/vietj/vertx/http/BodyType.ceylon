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
import ceylon.json { JSONObject=Object, parseJSON=parse }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }
import ceylon.io.charset { Charset }

by "Julien Viet"
license "ASL2"
doc "The type of an input body, this interface allows to parse the body of a stream plugable"
shared interface BodyType<out Body> {
	
	doc "Return true when this body type can parse the specified mime type"
	shared formal Boolean accept(String mimeType);
	
	doc "Parse the data with the specified charset and return the body"
	shared formal Body parse(Charset? charset, Buffer data);
}

doc "Binary body type"
shared object binaryBody satisfies BodyType<ByteBuffer> {
	shared actual Boolean accept(String mimeType) => true;
	shared actual ByteBuffer parse(Charset? charset, Buffer data) {
		Integer size = data.length();
		ByteBuffer buff = newByteBuffer(size);
		Integer index = 0;
		while (index < size) {
			Integer byte = data.getByte(index);
			buff.put(byte);
		}
		buff.flip();
		return buff;
	}
}

doc "String body type"
shared object textBody satisfies BodyType<String> {
	shared actual Boolean accept(String mimeType) => mimeType.equals("text/plain");
	shared actual String parse(Charset? charset, Buffer data) {
		if (exists charset) {
			return data.toString(charset.name);
		} else {
			return data.string;
		}
	}
}

doc "JSON body type"
shared object jsonBody satisfies BodyType<JSONObject> {
	shared actual Boolean accept(String mimeType) => mimeType.equals("application/json");
	shared actual JSONObject parse(Charset? charset, Buffer data) {
		String s = textBody.parse(charset, data);
		value parsed = parseJSON(s);
		return parsed;
	}
}

doc "Find a body type for the specified mime type"
shared BodyType<Anything> findBody(String mimeType) {
	for (bodyType in {textBody, jsonBody}) {
		if (bodyType.accept(mimeType)) {
			return bodyType;
		}
	}
	return binaryBody;
}

