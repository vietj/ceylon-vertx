import org.vertx.java.platform { Container_ = Container }
import org.vertx.java.core.json { JsonObject }
import ceylon.json { Object }
import io.vertx.ceylon.util { fromObject, toObject, HandlerPromise }
import java.lang { String_=String }
import ceylon.promise { Promise }
import ceylon.collection { HashMap }

JsonObject? toConf(Object? c) {
    if (exists c) {
        return fromObject(c);
    } else {
        return null;
    }
}

Deployment fa(Anything(String) undeploy)(String_? a) {
    if (exists a) {
        return Deployment(a.string, undeploy);
    } else {
        throw Exception();
    }
}

"""This class represents a Verticle's view of the container in which it is running.
   An instance of this class will be created by the system and made available to
   a running Verticle.
   It contains methods to programmatically deploy other verticles, undeploy
   verticles, deploy modules, get the configuration for a verticle and get the logger for a
   verticle, amongst other things.
   """
shared class Container(Container_ delegate) {
    
    value entries = delegate.env().entrySet().iterator();
    HashMap<String, String> tmp = HashMap<String, String>();
    while (entries.hasNext()) {
        value entry = entries.next();
        tmp.put(entry.key.string, entry.\ivalue.string);
    }
    
    // 
    "Get an unmodifiable map of system, environment variables."
    shared Map<String, String> env = tmp;

    "Get the verticle configuration"
    JsonObject? config_ = delegate.config();
    shared Object? config;
    if (exists config_) {
        config = toObject(delegate.config());
    } else {
        config = null;
    }
    
    "Cause the container to exit"
    shared void exit() {
        delegate.exit();
    }

    "Deploy a worker verticle programmatically. The returned promise will be resolved with the deployment or be rejected if it fails to deploy"
    shared Promise<Deployment> deployWorkerVerticle(
        "The main of the verticle"
        String main, 
        "The number of instances to deploy (defaults to 1)"
        Integer instance = 1, 
        "Multithreaded or not"
        Boolean multiThreaded = false, 
        "JSON config to provide to the verticle"
        Object? conf = null) {
        JsonObject? conf_ = toConf(conf);
        void undeploy(String s) {
            delegate.undeployVerticle(s);
        }
        HandlerPromise<Deployment, String_> a = HandlerPromise<Deployment, String_>(fa(undeploy));
        delegate.deployWorkerVerticle(main, conf_, instance, multiThreaded, a);
        return a.promise;
    }
    
    "Deploy a module programmatically. The returned promise will be resolved with the deployment or be rejected if it fails to deploy"
    shared Promise<Deployment> deployModule(
        "The main of the module to deploy"
        String moduleName, 
        "The number of instances to deploy (defaults to 1)"
        Integer instance = 1, 
        "JSON config to provide to the module"
        Object? conf = null) {
        JsonObject? conf_ = toConf(conf);
        void undeploy(String s) {
            delegate.undeployModule(s);
        }
        HandlerPromise<Deployment, String_> a = HandlerPromise<Deployment, String_>(fa(undeploy));
        delegate.deployModule(moduleName, conf_, instance, a);
        return a.promise;
    }

    "Deploy a verticle programmatically. The returned promise will be resolved with the deployment or be rejected if it fails to deploy"
    shared Promise<Deployment> deployVerticle(
        "The main of the verticle"
        String main, 
        "The number of instances to deploy (defaults to 1)"
        Integer instance = 1, 
        "JSON config to provide to the verticle"
        Object? conf = null) {
        JsonObject? conf_ = toConf(conf);
        void undeploy(String s) {
            delegate.undeployVerticle(s);
        }
        HandlerPromise<Deployment, String_> a = HandlerPromise<Deployment, String_>(fa(undeploy));
        delegate.deployVerticle(main, conf_, instance, a);
        return a.promise;
    }
    
}