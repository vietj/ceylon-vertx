import io.vertx.ceylon.util { ... }
import ceylon.json { ... }
import ceylon.collection { HashMap }
import ceylon.test { ... }
import org.vertx.java.core.json { JsonArray }

shared test void testCombine() {

    HashMap<String, [String+]> src = HashMap<String, [String+]> {
        "foo" -> ["foo_value_2"],
        "juu" -> ["juu_value"]
    };
    HashMap<String, [String+]> dst = HashMap<String, [String+]> {
        "foo" -> ["foo_value_1"],
        "bar" -> ["bar_value"]
    };
    value combined = combine { src=src; dst=dst; };
    assertEquals(HashMap<String, {String+}> {
        "foo" -> ["foo_value_1","foo_value_2"],
        "bar" -> ["bar_value"],
        "juu" -> ["juu_value"]
    }, combined);

}

shared test void testFromArray() {
    Array a = Array({"abc"});
    JsonArray b = fromArray(a);
    assertEquals(1, b.size());
    value i = b.iterator();
    value abc = i.next();
    assertEquals("abc", abc.string);
}
