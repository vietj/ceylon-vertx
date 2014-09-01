import org.vertx.java.core.http { HttpServerResponse_=HttpServerResponse }
import io.vertx.ceylon.stream { WriteStream, wrapWriteStream }
import io.vertx.ceylon.util { voidAsyncResult, putAll }
import ceylon.promise { Promise }
import org.vertx.java.core.buffer { Buffer }
import io.vertx.ceylon { Chunk }

"Represents a server-side HTTP response. Instances of this class are created and associated to every instance of
 [[HttpServerRequest]] that is created. It allows the developer to control the HTTP response that is sent back to the
 client for a particular HTTP request. It contains methods that allow HTTP  headers and trailers to be set, and
 for a body to be written out to the response.
 
 Instances of this class are not thread-safe."
by("Julien Viet")
shared class HttpServerResponse(HttpServerResponse_ delegate)
        extends HttpOutput<HttpServerResponse>() {

    shared actual WriteStream stream = wrapWriteStream(delegate);

    "Set the status code."
    shared HttpServerResponse status(
            "the status code value"
            Integer code,
            "the status message"
            String? message = null) {
        delegate.setStatusCode(code);
        if (exists message) {
            delegate.setStatusMessage(message);
        }
        return this;
    }

    shared actual HttpServerResponse write(Chunk chunk) {
        switch (chunk) 
        case (is String) {
            delegate.write(chunk);
        }
        case (is [String,String]) {
            delegate.write(chunk[0], chunk[1]);
        }
        case (is Buffer) {
          delegate.write(chunk);
        }
        return this;
    }

    shared actual HttpServerResponse end(Chunk? chunk) {
        switch (chunk) 
        case (is String) {
            delegate.end(chunk);
        }
        case (is [String,String]) {
            delegate.end(chunk[0], chunk[1]);
        }
        case (is Buffer) {
          delegate.end(chunk);
        }
        case (is Null) {
            delegate.end();
        }
        return this;
    }
    
    "Close the underlying TCP connection"
    shared void close() {
        delegate.close();
    }
    
    """If `chunked` is `true`, this response will use HTTP chunked encoding, and each call to write to the body will correspond to a new
       HTTP chunk sent on the wire.
       
       If chunked encoding is used the HTTP header {@code Transfer-Encoding} with a value of {@code Chunked} will be automatically
       inserted in the response.
       
       If chunked is `false`, this response will not use HTTP chunked encoding, and therefore if any data is written the body of
       the response, the total size of that data must be set in the {@code Content-Length} header <b>before</b> any data is written
       to the response body.
       
       An HTTP chunked response is typically used when you do not know the total size of the request body up front.
       """
    shared actual Boolean chunked => delegate.chunked;
    assign chunked => delegate.setChunked(chunked);

    shared actual HttpServerResponse headers({<String-><String|{String+}>>*} headers) {
        putAll(headers, delegate.headers());
        return this;
    }

    shared HttpServerResponse trailers({<String-><String|{String+}>>*} trailers) {
        putAll(trailers, delegate.trailers());
        return this;
    }
    
    """Tell the kernel to stream a file as specified by [[fileName]]] directly, from disk to the
       outgoing connection, bypassing userspace altogether (where supported by the underlying
       operating system. This is a very efficient way to serve files. It also takes the path [[notFoundFile]]
       to a resource to serve if the resource is not found"""
    shared Promise<Null> sendFile(String fileName, String? notFoundFile = null) {
      value result = voidAsyncResult();
      if (exists notFoundFile) {
        delegate.sendFile(fileName, notFoundFile, result);
      } else {
        delegate.sendFile(fileName, result);
      }
      return result.promise;
    }
    
}