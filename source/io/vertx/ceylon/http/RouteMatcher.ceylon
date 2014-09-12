import org.vertx.java.core.http { RouteMatcher_=RouteMatcher, HttpServerRequest_=HttpServerRequest }
import org.vertx.java.core { Handler_=Handler }

"""This class allows you to do route requests based on the HTTP verb and the request URI, in a manner similar
   to [Sinatra](http://www.sinatrarb.com/) or [Express](http://expressjs.com/).
   
   RouteMatcher also lets you extract paramaters from the request URI either a simple pattern or using
   regular expressions for more complex matches. Any parameters extracted will be added to the requests parameters
   which will be available to you in your request handler.
   
   It's particularly useful when writing REST-ful web applications.
   
   To use a simple pattern to extract parameters simply prefix the parameter name in the pattern with a ':' (colon).
   
   Different handlers can be specified for each of the HTTP verbs, GET, POST, PUT, DELETE etc.
   For more complex matches regular expressions can be used in the pattern. When regular expressions are used, the extracted
   parameters do not have a name, so they are put into the HTTP request with names of param0, param1, param2 etc.
   
   Multiple matches can be specified for each HTTP verb. In the case there are more than one matching patterns for
   a particular request, the first matching one will be used.
   
   Instances of this class are not thread-safe"""
by("Julien Viet")
shared class RouteMatcher() {
    
    value delegate = RouteMatcher_();
    
    Handler_<HttpServerRequest_> wrap(void handler(HttpServerRequest request)) {
        object impl satisfies Handler_<HttpServerRequest_> {
            shared actual void handle(HttpServerRequest_ e) {
                // Rewrapper avoids to use thread local
                // + it will compute the parameters again since they may have been modified
                // by the router
                handler(InternalHttpServerRequest(e));
            }
        }
        return impl;
    }
    
    shared void handle(HttpServerRequest request) {
        assert(is InternalHttpServerRequest request);
        delegate.handle(request.delegate);
    }
    
    "Specify a handler that will be called for a matching HTTP GET"
    shared void get("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.get(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP PUT"
    shared void put("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.put(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP POST"
    shared void post("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.post(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP DELETE"
    shared void delete("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.delete(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP OPTIONS"
    shared void options("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.options(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP HEAD"
    shared void head("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.head(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP TRACE"
    shared void trace("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.trace(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP CONNECT"
    shared void connect("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.connect(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP PATCH"
    shared void patch("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.patch(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for all HTTP methods"
    shared void all("The simple pattern" String pattern, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.all(pattern, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP GET"
    shared void getWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.getWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP PUT"
    shared void putWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.putWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP POST"
    shared void postWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.postWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP DELETE"
    shared void deleteWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.deleteWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP OPTIONS"
    shared void optionsWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.optionsWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP HEAD"
    shared void headWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.headWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP TRACE"
    shared void traceWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.traceWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP CONNECT"
    shared void connectWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.connectWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for a matching HTTP PATCH"
    shared void patchWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.patchWithRegEx(regex, wrap(handle));
    }
    
    "Specify a handler that will be called for all HTTP methods"
    shared void allWithRegEx("A regular expression" String regex, "The handler to call" void handle(HttpServerRequest request)) {
        delegate.allWithRegEx(regex, wrap(handle));
    }

    "Specify a handler that will be called when no other handlers match. If this handler is not specified default behaviour is to return a 404"
    shared void noMatch(void handle(HttpServerRequest request)) {
        delegate.noMatch(wrap(handle));
    }
}

