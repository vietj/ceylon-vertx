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
import vietj.vertx.util { combine }
import ceylon.collection { HashMap }
import ceylon.test { ... }

by "Julien Viet"
license "ASL2"
void testUtils() {
	
	HashMap<String, {String+}> src = HashMap<String, {String+}>({
		"foo" -> {"foo_value_2"},
		"juu" -> {"juu_value"}});
	HashMap<String, {String+}> dst = HashMap<String, {String+}>({
		"foo" -> {"foo_value_1"},
		"bar" -> {"bar_value"}});
	value combined = combine { src=src; dst=dst; };
	assertEquals(HashMap<String, {String+}>({
		"foo" -> {"foo_value_1","foo_value_2"},
		"bar" -> {"bar_value"},
		"juu" -> {"juu_value"}}), combined);
	
}