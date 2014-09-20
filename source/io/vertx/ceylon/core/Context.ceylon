import org.vertx.java.core { Context_=Context }
import io.vertx.ceylon.core.util { NoArgVoidHandler }

"Represents the execution context of a Verticle."
shared class Context(Context_ delegate) {
  
  shared void runOnContext(void task()) => delegate.runOnContext(NoArgVoidHandler(task));
  
}