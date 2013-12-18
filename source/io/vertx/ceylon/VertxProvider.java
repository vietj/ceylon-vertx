package io.vertx.ceylon;

import org.vertx.java.core.VertxFactory;
import org.vertx.java.core.Vertx;;

class VertxProvider {
	
	static Vertx create() {
		ClassLoader prev = Thread.currentThread().getContextClassLoader();
		try {
			Thread.currentThread().setContextClassLoader(VertxFactory.class.getClassLoader());
			return VertxFactory.newVertx();
		} finally {
			Thread.currentThread().setContextClassLoader(prev);
		}
	}

}
