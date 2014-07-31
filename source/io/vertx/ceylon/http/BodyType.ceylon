import org.vertx.java.core.buffer { Buffer }
import ceylon.json { JSONObject=Object, parseJSON=parse }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }
import ceylon.io.charset { Charset }

"The type of an input body, this interface allows to parse the body of a stream plugable"
by("Julien Viet")
shared interface BodyType<out Body> {

    "Return true when this body type can parse the specified mime type"
    shared formal Boolean accept(String mimeType);

    "Parse the data with the specified charset and return the body"
    shared formal Body parse(Charset? charset, Buffer data);

}

"Binary body type"
shared object binaryBody satisfies BodyType<ByteBuffer> {
	shared actual Boolean accept(String mimeType) => true;
	shared actual ByteBuffer parse(Charset? charset, Buffer data) {
		// This is likely not the most efficient way to do it
		// but for now it is ok
		Integer size = data.length();
		ByteBuffer buff = newByteBuffer(size);
		variable Integer index = 0;
		while (index < size) {
			Byte byte = data.getByte(index++);
			buff.put(byte);
		}
		buff.flip();
		return buff;
	}
}

"Text body type"
shared object textBody satisfies BodyType<String> {
	shared actual Boolean accept(String mimeType) => mimeType.startsWith("text/");
	shared actual String parse(Charset? charset, Buffer data) {
		if (exists charset) {
			return data.toString(charset.name);
		} else {
			return data.string;
		}
	}
}

"JSON body type"
shared object jsonBody satisfies BodyType<JSONObject> {
	shared actual Boolean accept(String mimeType) => mimeType.equals("application/json");
	shared actual JSONObject parse(Charset? charset, Buffer data) {
		String s = textBody.parse(charset, data);
		value parsed = parseJSON(s);
		assert(is JSONObject parsed);
		return parsed;
	}
}

"Find a body type for the specified mime type"
shared BodyType<Anything> findBody(String mimeType) {
	for (bodyType in {textBody, jsonBody}) {
		if (bodyType.accept(mimeType)) {
			return bodyType;
		}
	}
	return binaryBody;
}

