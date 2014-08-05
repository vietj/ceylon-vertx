import io.vertx.ceylon.stream { WriteStream }

"Provides access for writing the headers and  content of an
 [[HttpClientRequest]] or an [[HttpServerResponse]]."
by("Julien Viet")
shared abstract class HttpOutput<O>() given O satisfies HttpOutput<O> {

    "Set the response headers."
    shared formal O headers({<String-><String|{String+}>>*} headers);

    "Write a chunk to the output body."
    shared formal O write(
        """The data chunk to write:
           - when the argument is a `String` the `UTF-8` encoding is used
           - when the argument is a `[String,String]`, the first value is the chunk and the second is the encoding"""
        String|[String,String] chunk);
    
    "The write stream of this request"
    shared formal WriteStream stream;
    
    
    shared formal Boolean chunked;


    "Ends the response. If no data has been written to the response body,
     the actual response won't get written until this method gets called.
     Once the response has ended, it cannot be used any more."
    shared formal O end(
        """The optional data chunk to write as the response content:
           - when the argument is a `String` the `UTF-8` encoding is used
           - when the argument is a `[String,String]`, the first value is the chunk and the second is the encoding"""
        <String|[String,String]>? chunk = null);

    "Set the content type of the response."
    shared default O contentType(String mimeType, String charset = "UTF-8") {
        return headers { "Content-Type" -> "``mimeType``; charset=``charset``" };
    }
}