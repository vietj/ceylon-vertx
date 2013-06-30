import vietj.vertx { toMap }
import vietj.promises { Promise }
import org.vertx.java.core.http { HttpClientResponse_=HttpClientResponse }

shared class HttpClientResponse(HttpClientResponse_ delegate) extends HttpInput() {
	
	shared Integer status => delegate.statusCode();
	
	doc "The http headers"
	shared actual Map<String,{String+}> headers = toMap(delegate.headers());
	
	// We must pause
	delegate.pause();
	
	shared actual Promise<Body> getBody<Body>(BodyType<Body> parser) {
		return parseBody(parser, delegate.bodyHandler, delegate, charset);
	}
}