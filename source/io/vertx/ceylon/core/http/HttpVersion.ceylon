"The HTTP version"
shared abstract class HttpVersion() of http_1_0 | http_1_1 {}

"HTTP 1.0"
shared object http_1_0 extends HttpVersion() {}

"HTTP 1.1"
shared object http_1_1 extends HttpVersion() {}
