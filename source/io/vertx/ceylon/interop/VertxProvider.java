package io.vertx.ceylon.interop;

import org.vertx.java.core.VertxFactory;
import org.vertx.java.core.Vertx;

;

public class VertxProvider {

	public static Vertx create() {
		ClassLoader prev = Thread.currentThread().getContextClassLoader();
		try {
			Thread.currentThread().setContextClassLoader(
					VertxFactory.class.getClassLoader());
			return VertxFactory.newVertx();
		} finally {
			Thread.currentThread().setContextClassLoader(prev);
		}
	}

}
