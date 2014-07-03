package io.vertx.ceylon.interop;

import org.vertx.java.core.Handler;
import org.vertx.java.core.streams.ExceptionSupport;

import ceylon.promise.Deferred;

public class ExceptionSupportAdapter {
	
	public static <T, U> void setErrorHandler(ExceptionSupport<T> es, final Deferred<U> deferred) {
		es.exceptionHandler(new Handler<Throwable>() {
			@Override
			public void handle(Throwable t) {
				deferred.reject(t);
			}
		});
	}
}
