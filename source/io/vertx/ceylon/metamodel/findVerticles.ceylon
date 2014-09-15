import ceylon.language.meta {
	modules
}
import ceylon.language.meta.declaration {
	Module,
	ClassDeclaration,
	OpenType,
	OpenClassType
}
import io.vertx.ceylon { Vertx }
import io.vertx.ceylon.platform {
	Verticle, Container
}
import java.lang { JavaString = String }
import org.vertx.java.platform { JavaVerticle = Verticle }
import java.util { ArrayList, List, Set }
import java.util.concurrent { Callable }

OpenType verticleDecl = `class Verticle`.openType;
Boolean isVerticle(OpenType classDecl) {
	if (is OpenClassType classDecl) {
		if (exists ext = classDecl.extendedType) {
			if (ext == verticleDecl) {
				return true;
			} else {
				return isVerticle(ext);
			}
		}
	}
	return false;
}

"Find the verticles among the known modules and return a list of verticle factories"
shared List<Callable<JavaVerticle>> findVerticles("The set of module names" Set<JavaString> moduleNames) {
	value verticles = ArrayList<Callable<JavaVerticle>>();
	value mods = modules.list.filter((Module elem) => moduleNames.contains(JavaString(elem.name)));
	for (mod in mods) {
		for (pkg in mod.members) {
			for (classDecl in pkg.members<ClassDeclaration>()) {
				if (isVerticle(classDecl.openType)) {
					value instance = classDecl.instantiate();
					assert(is Verticle instance);
					object factory satisfies Callable<JavaVerticle> {
					  shared actual JavaVerticle call() {
					    object adapter extends JavaVerticle() {
					      shared actual void start() {
					        Vertx vertx = Vertx(this.vertx);
					        Container container = Container(this.container);
					        instance.doStart(vertx, container);
					      }
					      shared actual void stop() {
					        instance.doStop();
					      }
					    }
					    return adapter;
					  }
					}
					verticles.add(factory);
				}
			}
		}
	}
	return verticles;
}