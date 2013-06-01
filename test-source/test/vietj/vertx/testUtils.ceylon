import vietj.vertx { combine }
import ceylon.collection { HashMap }
import ceylon.test { ... }

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