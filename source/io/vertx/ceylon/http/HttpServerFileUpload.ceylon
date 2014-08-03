import io.vertx.ceylon {
  ReadStream, createReadStream=wrapReadStream
}
import org.vertx.java.core.http { HttpServerFileUpload_=HttpServerFileUpload }
import ceylon.io.charset {
  Charset, getCharset
}

"Represents an upload from an HTML form."
shared class HttpServerFileUpload(HttpServerFileUpload_ delegate) {
  
  shared ReadStream readStream = createReadStream(delegate);

  "Stream the content of this upload to the given [[filename]]"
  shared HttpServerFileUpload streamToFileSystem(String fileName) {
    delegate.streamToFileSystem(fileName);
    return this;
  }
  
  "Returns the filename which was used when upload the file"
  shared String filename => delegate.filename();
  
  "Returns the name of the attribute"
  shared String name => delegate.name();
  
  "Returns the contentType for the upload"
  shared String contentType => delegate.contentType();
  
  "Returns the contentTransferEncoding for the upload"
  shared String contentTransferEncoding => delegate.contentTransferEncoding();
  
  "Returns the charset for the upload"
  shared Charset charset {
    value c = getCharset(delegate.charset().name());
    assert(exists c);
    return c;
  }
  
  "Returns the size of the upload (in bytes)"
  shared Integer size => delegate.size();
  
}