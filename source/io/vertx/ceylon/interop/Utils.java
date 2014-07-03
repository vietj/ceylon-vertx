package io.vertx.ceylon.interop;

import org.vertx.java.core.streams.ReadStream;
import org.vertx.java.core.streams.WriteStream;

public class Utils {
	
	@SuppressWarnings("unchecked")
	public static <T> ReadStream<Object> rawReadStream(ReadStream<T> readStream) {
		// Necessary Evil!!!
		return (ReadStream<Object>)readStream;
	}

	@SuppressWarnings("unchecked")
	public static <T> WriteStream<Object> rawWriteStream(WriteStream<T> writeStream) {
		// Necessary Evil!!!
		return (WriteStream<Object>)writeStream;
	}
}
