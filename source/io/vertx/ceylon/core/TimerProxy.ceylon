import org.vertx.java.core { Handler_=Handler }
import java.lang { Long_=Long }

class TimerProxy(void handler(Integer id)) satisfies Handler_<Long_> {
    shared actual void handle(Long_? e) {
        assert(exists e);
        handler(e.longValue());
    }
}