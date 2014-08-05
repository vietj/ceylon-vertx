import ceylon.promise { Promise, Deferred }
import org.vertx.java.core.buffer { Buffer }
import org.vertx.java.core { Handler_=Handler }
import org.vertx.java.core.streams { ReadStream_=ReadStream }
import ceylon.io.charset { Charset, getCharset }
import io.vertx.ceylon.interop { ExceptionSupportAdapter { setErrorHandler } }
import io.vertx.ceylon.stream { ReadStream }

"Provides access for reading the http headers and the body of an [[HttpServerRequest]] or an [[HttpClientResponse]]."
by("Julien Viet")
shared abstract class HttpInput() {
    
    variable [String?, Charset?]? _contentType = null;

    [String?, Charset?] contentType {
        if (exists tmp = _contentType) {
            return tmp;
        } else {
            String? mimeType;
            Charset? charset;
            if (exists contentType = headers["Content-Type"]) {
                if (exists pos = contentType.first.firstOccurrence(';')) {
                    mimeType = contentType.first[0:pos].trimmed;
                    if (exists charsetPos = contentType.first.lastOccurrence('=')) {
                        value name = contentType.first[charsetPos+1:contentType.first.size];
                        charset = getCharset(name);
                    } else {
                        charset = null;
                    }
                } else {
                    mimeType = contentType.first.trimmed;
                    charset = null;
                }
            } else {
                mimeType = null;
                charset = null;
            }
            value ret = [mimeType, charset];
            _contentType = ret;
            return ret;
        }
    }

    "The headers"
    shared formal Map<String,{String+}> headers;

    "The charset or null"
    shared default Charset? charset {
        return contentType[1];
    }

    "The mime type or null"
    shared default String? mimeType {
        return contentType[0];
    }

    "Parse the input body, the returned promise is resolved with the body."
    shared formal Promise<Body> parseBody<Body>(BodyType<Body> parser);
    
    "The read stream of this request"
    shared formal ReadStream stream;

}

"Parse the body of an input"
Promise<Body> doParseBody<Body, T>(
        BodyType<Body> bodyType,
        Anything(Handler_<Buffer>) setBodyHandler,
        ReadStream_<T> stream,
        Charset? charset) {

    //
    Deferred<Body> deferred = Deferred<Body>();

    //
    object valueHandler satisfies Handler_<Buffer> {
        shared actual void handle(Buffer buffer) {
            try {
                Body body = bodyType.parse(charset, buffer);
                deferred.fulfill(body);
            } catch(Exception e) {
                deferred.reject(e);
            }
        }
    }

    // Set handlers and resume the paused handler
    setBodyHandler(valueHandler);
    setErrorHandler(stream, deferred);

    //
    return deferred.promise;
}
