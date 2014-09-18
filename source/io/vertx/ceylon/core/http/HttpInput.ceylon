import ceylon.io.charset { Charset, getCharset }
import io.vertx.ceylon.core.stream { ReadStream }
import io.vertx.ceylon.core { MultiMap }
import ceylon.promise { Promise }
import io.vertx.ceylon.core.net {
  NetSocket
}

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
    shared formal MultiMap headers;

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

    "Get a net socket for the underlying connection of this request. USE THIS WITH CAUTION!
     Writing to the socket directly if you don't know what you're doing can easily break the HTTP protocol"
    shared formal NetSocket netSocket();
    
}
