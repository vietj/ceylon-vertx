package io.vertx.ceylon.interop;

import org.vertx.java.core.streams.ReadStream;
import org.vertx.java.core.streams.WriteStream;

public class Utils {
	
	// Todo : remove it
	@SuppressWarnings("unchecked")
	public static <T> ReadStream<Object> rawReadStream(ReadStream<? extends T> readStream) {
		// Necessary Evil!!!
		return (ReadStream<Object>)readStream;
	}

	// Todo : remove it
	@SuppressWarnings("unchecked")
	public static <T> WriteStream<Object> rawWriteStream(WriteStream<? extends T> writeStream) {
		// Necessary Evil!!!
		return (WriteStream<Object>)writeStream;
	}
}
