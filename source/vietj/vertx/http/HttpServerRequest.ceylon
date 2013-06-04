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

import org.vertx.java.core.http { HttpServerRequest_=HttpServerRequest }
import ceylon.net.uri { Uri, parseUri=parse, Query, Parameter }
import ceylon.io { SocketAddress }
import ceylon.collection { HashMap }
import vietj.vertx { combine, toMap }

by "Julien Viet"
license "ASL2"
shared class HttpServerRequest(HttpServerRequest_ delegate, Map<String, {String+}>? formParameters_ = null) {
	
	shared HttpServerResponse response = HttpServerResponse(delegate.response());
	shared String method => delegate.method();
	shared Uri uri => parseUri(delegate.uri());
	shared String path => delegate.path();
	shared Query query => uri.query;
	shared Map<String, {String+}>? formParameters = formParameters_;
	shared SocketAddress remoteAddress = SocketAddress(delegate.remoteAddress().address.hostAddress, delegate.remoteAddress().port);
	
	// Compute query parameter map
	variable Map<String, {String+}>? queryMap = null;
	Map<String, {String+}> getQueryMap() {
		if (exists ret = queryMap) {
			return ret;
		} else {
			HashMap<String, {String+}> map = HashMap<String, {String+}>();
			for (Parameter parameter in query.parameters.reversed) {
				if (exists val = parameter.val) {
					variable {String+}? previous = map[parameter.name];
					{String+} values;
					if (exists rest = previous) {
						values = { val, *rest };
					} else {
						values = { val };
					}
					map.put(parameter.name, values);
				} 
			}
			return queryMap = map;
		}
	}
	shared Map<String, {String+}> queryParameters => getQueryMap();
	
	// Compute parameter map
	variable Map<String,{String+}>? parameterMap = null;
	Map<String, {String+}> getParameterMap() {
		if (exists ret = parameterMap) {
			return ret;
		} else {
			if (exists formParameters) {
				return parameterMap = combine(formParameters, combine(queryParameters));
			} else {
				return parameterMap = queryParameters;
			}
		}
	}
	shared Map<String, {String+}> parameters => getParameterMap();
	
	// Compute header map
	variable Map<String,{String+}>? headerMap = null;
	Map<String,{String+}> getHeaderMap() {
		if (exists ret = headerMap) {
			return ret;
		} else {
			value headersMM = delegate.headers();
			return headerMap = toMap(headersMM);
		}
	}
	shared Map<String, {String+}> headers => getHeaderMap();
}