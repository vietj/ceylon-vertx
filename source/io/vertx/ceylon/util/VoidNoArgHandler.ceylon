import org.vertx.java.core { Handler_=Handler }
import java.lang { Void_=Void }

shared class VoidNoArgHandler(void done()) satisfies Handler_<Void_> {
  shared actual void handle(Void_ v) {
    done();
  }
}