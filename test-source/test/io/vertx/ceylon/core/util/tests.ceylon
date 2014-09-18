import io.vertx.ceylon.core.util { ... }
import ceylon.json { JsonArray=Array, JsonObject=Object }
import ceylon.collection { HashMap }
import ceylon.test { ... }
import org.vertx.java.core.json { JsonArray_=JsonArray, JsonObject_=JsonObject }
import java.lang { String_=String, Long_=Long, Boolean_=Boolean, Double_=Double, Integer_=Integer, Byte_=Byte, Float_=Float, Short_=Short }

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

shared test void testFromJson() {
  value src = JsonObject{"a"->"b","b"->123,"c"->true,"d"->1.1,"e"->JsonArray{"b",123,true,1.1,JsonObject{},JsonArray{}},"f"->JsonObject{}};
  value dst = toJsonObject(src);
  assertEquals(dst.getField("a"), String_("b"));
  assertEquals(dst.getField("b"), Long_(123));
  assertEquals(dst.getField("c"), Boolean_(true));
  assertEquals(dst.getField("d"), Double_(1.1));
  value array = dst.getArray("e");
  assertEquals(array.get(0), String_("b"));
  assertEquals(array.get(1), Long_(123));
  assertEquals(array.get(2), Boolean_(true));
  assertEquals(array.get(3), Double_(1.1));
  assertEquals(array.get(4), JsonObject_());
  assertEquals(array.get(5), JsonArray_());
  assertEquals(dst.getField("f"), JsonObject_());
}

shared test void testToJson() {
  value src = JsonObject_();
  src.putString("string", "s");
  src.putBoolean("boolean", Boolean_.\iTRUE);
  src.putNumber("byte", Byte_(123.byte));
  src.putNumber("short", Short_(1234));
  src.putNumber("integer", Integer_(123456));
  src.putNumber("long", Long_(12345678));
  src.putNumber("float", Float_.valueOf(Float_.parseFloat("3.14")));
  src.putNumber("double", Double_.valueOf(Double_.parseDouble("3.14")));
  src.putObject("object", JsonObject_());
  value array =JsonArray_();
  array.addString("s");
  array.addBoolean(Boolean_.\iTRUE);
  array.addNumber(Byte_(123.byte));
  array.addNumber(Short_(1234));
  array.addNumber(Integer_(123456));
  array.addNumber(Long_(12345678));
  array.addNumber(Float_.valueOf(Float_.parseFloat("3.14")));
  array.addNumber(Double_.valueOf(Double_.parseDouble("3.14")));
  array.addObject(JsonObject_());
  array.addArray(JsonArray_());
  src.putArray("array", array);
  value dst = fromJsonObject(src);
  assertEquals(dst["string"], "s");
  assertEquals(dst["boolean"], true);
  assertEquals(dst["byte"], 123);
  assertEquals(dst["short"], 1234);
  assertEquals(dst["integer"], 123456);
  assertEquals(dst["long"], 12345678);
  assertEquals(dst["float"], 3.140000104904175);
  assertEquals(dst["double"], 3.14);
  assertEquals(dst["object"], JsonObject());
  value dstArray = dst["array"];
  assert(is JsonArray dstArray);
  assertEquals(dstArray[0], "s");
  assertEquals(dstArray[1], true);
  assertEquals(dstArray[2], 123);
  assertEquals(dstArray[3], 1234);
  assertEquals(dstArray[4], 123456);
  assertEquals(dstArray[5], 12345678);
  assertEquals(dstArray[6], 3.140000104904175);
  assertEquals(dstArray[7], 3.14);
  assertEquals(dstArray[8], JsonObject());
  assertEquals(dstArray[9], JsonArray());
}
