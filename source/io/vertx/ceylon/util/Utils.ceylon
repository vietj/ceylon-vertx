import ceylon.collection { HashMap }
import ceylon.json { JsonObject=Object, JsonArray=Array }
import org.vertx.java.core { MultiMap_=MultiMap }
import org.vertx.java.core.json { JsonObject_=JsonObject, JsonArray_=JsonArray }
import java.lang { Character_=Character, String_=String, Iterable_=Iterable, ObjectArray_=ObjectArray, Long_=Long, Boolean_=Boolean, Double_=Double, Byte_=Byte, Short_=Short, Float_=Float, Integer_=Integer }
import java.util { ArrayList_=ArrayList }
import io.vertx.ceylon { MultiMap }
import ceylon.language.meta.model { Type }

by("Julien Viet")
shared HashMap<String, [String+]> combine(
        Map<String, [String+]> src,
        HashMap<String, [String+]> dst = HashMap<String, [String+]>()) {

    for (entry in src) {
        value name = entry.key;
        variable value val = entry.item;
        value previous = dst[name];
        if (exists previous) {
            for (i in previous) {
                val = [i, *val];
            }
        }
        dst.put(name, val);
    }
    return dst;
}

Type<Byte> byteType = `Byte`;

shared T|Absent fromObject<T>(Object? obj) {
  if (is String_ obj) {
    value ret = obj.string;
    if (is T ret) {
      return ret;
    }
  } else if (is Boolean_ obj) {
    value ret = obj.booleanValue();
    if (is T ret) {
      return ret;
    }
  } else if (is Character_ obj) {
    value ret = obj.charValue();
    if (is T ret) {
      return ret;
    }
  } else if (is JsonObject_ obj) {
    value ret = fromJsonObject(obj);
    if (is T ret) {
      return ret;
    }
  } else if (is JsonArray_ obj) {
    value ret = fromJsonArray(obj);
    if (is T ret) {
      return ret;
    }
  } else if (is <Byte_|Short_|Integer_|Long_> obj) {
    value ret = Integer(obj.longValue());
    value type = `T`;
    if (type == byteType) {
      assert(is T t = ret.byte);
      return t;
    } else if (is T ret) {
      return ret;
    }
  } else if (is <Float_|Double_> obj) {
    value ret = Float(obj.doubleValue());
    if (is T ret) {
      return ret;
    }
  } else if (is T obj) {
    return obj;
  }
  return absent;
}

"Convert a Vert.x MultiMap to a Ceylon map"
shared MultiMap toMap(MultiMap_ multiMap) {
    return MultiMap(multiMap);
}

"Put the entries in the provided Vert.x MultiMap"
shared void putAll({<String-><String|{String+}>>*} entries, MultiMap_ multiMap) {
  for (entry in entries) {
    value item = entry.item;
    switch (item)
    case (is String) {
      multiMap.set(entry.key, item);
    }
    case (is {String+}) {
      Iterable_<String_> i = toStringIterable(item);
      multiMap.set(entry.key, i);
    }
  }
}

"Convert a ceylon.json.Object to a Vert.x JsonObject"
shared JsonObject_ toJsonObject(JsonObject obj) {
    value o = JsonObject_();
    for (field in obj) {
        value val = field.item;
        switch (val)
        case (is String) { o.putString(field.key, val); }
        case (is JsonObject) { o.putObject(field.key, toJsonObject(val)); }
        case (is JsonArray) { o.putArray(field.key, toJsonArray(val)); }
        case (is Integer) { o.putNumber(field.key, Long_(val)); }
        case (is Boolean) { o.putBoolean(field.key, Boolean_(val)); }
        case (is Float) { o.putNumber(field.key, Double_(val)); }
        else { throw Exception("Conversion of ``field`` not supported"); }
    }
    return o;
}

"Convert a ceylon.json.Array to a Vert.x JsonArray"
shared JsonArray_ toJsonArray(JsonArray array) {
    value jsonArray = JsonArray_();
    for (jsonElement in array) {
        switch (jsonElement)
        case (is String) { jsonArray.addString(jsonElement); }
        case (is JsonObject) { jsonArray.addObject(toJsonObject(jsonElement)); }
        case (is JsonArray) { jsonArray.addArray(toJsonArray(jsonElement)); }
        case (is Integer) { jsonArray.addNumber(Long_(jsonElement)); }
        case (is Boolean) { jsonArray.addBoolean(Boolean_(jsonElement)); }
        case (is Float) { jsonArray.addNumber(Double_(jsonElement)); }
        else { throw Exception("Conversion of ``jsonElement`` not supported"); }
    }
    return jsonArray;
}

"Convert a Vert.x JsonObject to a ceylon.json.Object"
shared JsonObject fromJsonObject(JsonObject_ jsonObject) {
    value obj = JsonObject();
    value iterator = jsonObject.fieldNames.iterator();
    while (iterator.hasNext()) {
        value next = iterator.next();
        String fieldName = next.string;
        value fieldValue = jsonObject.getField<Object>(fieldName);
        switch (fieldValue)
        case (is String_) { obj.put(fieldName, fieldValue.string); }
        case (is JsonObject_) { obj.put(fieldName, fromJsonObject(fieldValue)); }
        case (is JsonArray_) { obj.put(fieldName, fromJsonArray(fieldValue)); }
        case (is Boolean_) { obj.put(fieldName, fieldValue.booleanValue()); }
        case (is Byte_|Short_|Integer_|Long_) { obj.put(fieldName, fieldValue.longValue()); }
        case (is Float_|Double_) { obj.put(fieldName, fieldValue.doubleValue()); }
        else { throw Exception("Conversion of ``fieldValue`` not supported"); }
    }
    return obj;
}

"Convert a Vert.x JsonArray to a ceylon.json.Array"
shared JsonArray fromJsonArray(JsonArray_ jsonArray) {
    value array = JsonArray();
    if (jsonArray.size() > 0) {
        value iterator = jsonArray.iterator();
        while (iterator.hasNext()) {
            value element = iterator.next();
            switch(element) 
            case (is String_) { array.add(element.string); }
            case (is JsonObject_) { array.add(fromJsonObject(element)); }
            case (is JsonArray_) { array.add(fromJsonArray(element)); }
            case (is Boolean_) { array.add(element.booleanValue()); }
            case (is Byte_|Short_|Integer_|Long_) { array.add(element.longValue()); }
            case (is Float_|Double_) { array.add(element.doubleValue()); }
            else { throw Exception("todo"); }
        }
    }
    return array;
}

shared Iterable_<String_> toStringIterable({String*} strings) {
    ArrayList_<String_> list = ArrayList_<String_>();
    for (element in strings) {
        list.add(String_(element));
    }
    return list;
}

shared {String*} fromStringArray(ObjectArray_<String_> v) {
  return v.iterable.coalesced.map((String_ s) => s.string);
}
