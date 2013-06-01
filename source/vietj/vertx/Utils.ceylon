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

import ceylon.collection { HashMap }
import org.vertx.java.core { MultiMap }
import java.lang { String_=String }
import java.util { Iterator_=Iterator }

by "Julien Viet"
license "ASL2"
shared HashMap<String, {String+}> combine(Map<String, {String+}> src, HashMap<String, {String+}> dst = HashMap<String, {String+}>()) {
	for (entry in src) {
		value name = entry.key;
		variable value val = entry.item;
		value previous = dst[name];
		if (exists previous) {
			for (i in previous) {
				val = {i, *val};
			}
		}
		dst.put(name, val);
	}
	return dst;
}

@doc "Convert a Vert.x MultiMap to a Ceylon map"
shared Map<String, {String+}> toMap(MultiMap multiMap) {
	HashMap<String, {String+}> map = HashMap<String, {String+}>();
	value keyIterator = multiMap.names().iterator();
	while (keyIterator.hasNext()) {
		value nextKey = keyIterator.next();
		String key = nextKey.string;
		
		// Recurse to build the values in correct order 
		{String+} read(Iterator_<String_> i) {
			value val = i.next().string;
			if (i.hasNext()) {
				return { val, *read(i) };
			} else {
				return { val };
			}
		}
		value values = read(multiMap.getAll(key).iterator());
		map.put(key, values);
	}
	return map;
}
