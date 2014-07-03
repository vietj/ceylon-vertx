import org.vertx.java.platform { PlatformManager, PlatformLocator { f = factory } }
import ceylon.json { Object }
import ceylon.promise { Promise }
import org.vertx.java.core.json { JsonObject }
import io.vertx.ceylon.util { HandlerPromise }
import java.lang { String_ = String }
import io.vertx.ceylon { Vertx }

"""Represents the Vert.x platform.
   
   It's the role of a PlatformManager to deploy and undeploy modules and verticles. It's also used to install
   modules, and for various other tasks.
   
   The Platform Manager basically represents the Vert.x container in which verticles and modules run.
   
   The Platform Manager is used by the Vert.x CLI to run/install/etc modules and verticles but you could also
   use it if you want to embed the entire Vert.x container in an application, or write some other tool (e.g.
   a build tool, or a test tool) which needs to do stuff with the container.
   """
shared class Platform() {

	PlatformManager manager = f.createPlatformManager();
	
	"Deploy a module. The returned promise will be resolved with the deployment or be rejected if it fails to deploy"
	shared Promise<Deployment> deploy(
		"The name of the module to deploy"
		String moduleName,
		"Any JSON config to pass to the verticle, or null if none"
		Object? conf, 
		"fromObject(conf)"
		Integer instances) {
		JsonObject? vertxConf = toConf(conf);
		void undeploy(String s) {
			manager.undeploy(s, null);
		}
		HandlerPromise<Deployment, String_> a = HandlerPromise<Deployment, String_>(fa(undeploy));
		manager.deployModule(moduleName, vertxConf, instances, a);
		return a.promise;
	}
	
	"The Vertx instance used by the platform manager"
	shared Vertx vertx = Vertx(manager.vertx());
	
	"Stop the platform manager"
	shared void stop() {
		manager.stop();
	}
	
}