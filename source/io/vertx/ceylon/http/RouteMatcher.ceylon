/*
 * Copyright 2013 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import org.vertx.java.core.http { RouteMatcher_=RouteMatcher, HttpServerRequest_=HttpServerRequest }
import org.vertx.java.core { Handler_=Handler }
import java.lang { ThreadLocal }

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
    value current = ThreadLocal<HttpServerRequest>();
    
    Handler_<HttpServerRequest_> wrap(void handler(HttpServerRequest request)) {
        object impl satisfies Handler_<HttpServerRequest_> {
            shared actual void handle(HttpServerRequest_ e) {
                value request = current.get();
                handler(request);
            }
        }
        return impl;
    }
    
    shared void handle(HttpServerRequest request) {
        assert(is InternalHttpServerRequest request);
        current.set(request);
        try {
            delegate.handle(request.delegate);
        } finally {
            current.set(null);
         }
    }
    
    "Specify a handler that will be called for a matching HTTP GET"
    shared void get("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.get(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP PUT"
    shared void put("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.put(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP POST"
    shared void post("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.post(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP DELETE"
    shared void delete("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.delete(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP OPTIONS"
    shared void options("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.options(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP HEAD"
    shared void head("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.head(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP TRACE"
    shared void trace("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.trace(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP CONNECT"
    shared void connect("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.connect(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP PATCH"
    shared void patch("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.patch(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for all HTTP methods"
    shared void all("The simple pattern" String pattern, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.all(pattern, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP GET"
    shared void getWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.getWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP PUT"
    shared void putWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.putWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP POST"
    shared void postWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.postWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP DELETE"
    shared void deleteWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.deleteWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP OPTIONS"
    shared void optionsWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.optionsWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP HEAD"
    shared void headWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.headWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP TRACE"
    shared void traceWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.traceWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP CONNECT"
    shared void connectWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.connectWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for a matching HTTP PATCH"
    shared void patchWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.patchWithRegEx(regex, wrap(handler));
    }
    
    "Specify a handler that will be called for all HTTP methods"
    shared void allWithRegEx("A regular expression" String regex, "The handler to call" void handler(HttpServerRequest request)) {
        delegate.allWithRegEx(regex, wrap(handler));
    }

    "Specify a handler that will be called when no other handlers match. If this handler is not specified default behaviour is to return a 404"
    shared void noMatch(void handler(HttpServerRequest request)) {
        delegate.noMatch(wrap(handler));
    }
}
