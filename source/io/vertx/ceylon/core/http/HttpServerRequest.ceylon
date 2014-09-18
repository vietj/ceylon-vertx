import org.vertx.java.core.http { HttpServerRequest_=HttpServerRequest, HttpVersion_=HttpVersion { http_1_0_=HTTP_1_0} }
import ceylon.io { SocketAddress }
import io.vertx.ceylon.core.util { toMap, FunctionalHandlerAdapter }
import ceylon.promise { Promise, Deferred }
import io.vertx.ceylon.core.stream { ReadStream }
import org.vertx.java.core { Handler_=Handler }
import java.lang { Void_=Void }
import io.vertx.ceylon.core { MultiMap }

"Represents a server-side HTTP request. Each instance of this class is associated with a corresponding
 [[HttpServerResponse]] instance via the `response` field. Instances of this class are not thread-safe."
by("Julien Viet")
shared class HttpServerRequest(HttpServerRequest_ delegate) extends HttpInput() {
        
    "The response. Each instance of this class has an [[HttpServerResponse]] instance attached to it.
     This is used to send the response back to the client."
    shared HttpServerResponse response = HttpServerResponse(delegate.response());
    
    "The HTTP version of the request."
    shared HttpVersion version = delegate.version() == http_1_0_ then http_1_0 else http_1_1;
    
    shared actual ReadStream stream = ReadStream(delegate);

    "The request method"
    shared String method = delegate.method();

    "The request uri"
    shared String uri => delegate.uri();

    "The request path"
    shared String path => delegate.path();

    "The query part of the request uri"
    shared String query => delegate.query();
    
    "Get the absolute URI corresponding to the the HTTP request"
    shared String absoluteURI => delegate.absoluteURI().string;

    variable Deferred<MultiMap>? formDeferred = null;
    
    "The form attributes when the request is a POST/PUT/PATCH with a _application/x-www-form-urlencoded_ or _multipart/form-data_ mime type" 
    shared Promise<MultiMap> formAttributes {
        if (exists t = formDeferred) {
            return t.promise;
        } else {
            value d = Deferred<MultiMap>();
            String? contentType = delegate.headers().get("Content-Type");
            
            if (exists contentType,
              (contentType.lowercased.startsWith("application/x-www-form-urlencoded") ||
               contentType.lowercased.startsWith("multipart/form-data")
              ) && (method == "POST" || method == "PUT" || method == "PATCH")) {
                object handler satisfies Handler_<Void_> {
                    shared actual void handle(Void_ nothing) {
                        value formAttributesMap = delegate.formAttributes();
                        MultiMap form = toMap(formAttributesMap);
                        d.fulfill(form);
                    }
                } 
                delegate.expectMultiPart(true);
                delegate.endHandler(handler); 
                formDeferred = d;
            } else {
                d.reject(Exception("Request does not have an application/x-www-form-urlencoded body and is not among POST,PUT,PATCH"));
            }
            return d.promise;
        }
    }

    "The remote socket address"
    shared SocketAddress remoteAddress = SocketAddress {
        address = delegate.remoteAddress().address.hostAddress;
        port = delegate.remoteAddress().port;
    };

    // Lazy params map
    variable MultiMap? paramsMap = null;

    "Returns a map of all the parameters in the request."
    shared MultiMap params {
        if (exists ret = paramsMap) {
            return ret;
        } else {
            value a = toMap(delegate.params());
            paramsMap = a;
            return a;
        }
    }

    // Lazy header map
    variable MultiMap? headerMap = null;
    shared actual MultiMap headers {
        if (exists ret = headerMap) {
            return ret;
        } else {
            value headersMM = delegate.headers();
            return headerMap = toMap(headersMM);
        }
    }

    shared actual Promise<Body> parseBody<Body>(BodyType<Body> parser) {
        return doParseBody(parser, delegate.bodyHandler, delegate, charset);
    }
    
    shared HttpServerRequest expectMultiPart(Boolean expect) {
      delegate.expectMultiPart(expect);
      return this;
    }
    
    shared HttpServerRequest uploadHandler(void onUpload(HttpServerFileUpload upload)) {
      delegate.uploadHandler(FunctionalHandlerAdapter(HttpServerFileUpload, onUpload));
      return this;
    }
    
}

class InternalHttpServerRequest(shared HttpServerRequest_ delegate)
    extends HttpServerRequest(delegate) {
}