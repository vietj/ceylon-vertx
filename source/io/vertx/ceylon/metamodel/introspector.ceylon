import ceylon.language.meta {
	modules,
  type
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
import java.util { ArrayList, List }

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

shared List<JavaVerticle> introspector(List<JavaString> moduleNames) {
	value verticles = ArrayList<JavaVerticle>();
	value mods = modules.list.filter((Module elem) => moduleNames.contains(JavaString(elem.name)));
	print("Introspecting modules ``mods``");
	for (mod in mods) {
		print("Introspecting module " + mod.name);
		for (pkg in mod.members) {
			print("Introspecting package ``pkg``");
			for (classDecl in pkg.members<ClassDeclaration>()) {
				print("Introspecting class ``classDecl``");
				if (isVerticle(classDecl.openType)) {
					print("Found verticle ``classDecl``");
					value instance = classDecl.instantiate();
					if (exists instance) {
						print("Instantiated verticle ``instance``");
						if (is Verticle instance) {
							object adapter extends JavaVerticle() {
								shared actual void start() {
									Vertx vertx = Vertx(this.vertx);
									Container container = Container(this.container);
									instance.start(vertx, container);
								}
								shared actual void stop() {
									instance.stop();
								}
							}
							verticles.add(adapter);
						} else {
							value a = type(instance);
							print("Create instance of type ``a`` does not satisfies Verticle");
						}
					} else {
						throw Exception();
					}
				}
			}
		}
	}
	return verticles;
}