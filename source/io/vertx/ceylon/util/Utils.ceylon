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
import ceylon.json { Object, Array }
import org.vertx.java.core { MultiMap }
import org.vertx.java.core.json { JsonObject, JsonArray }
import java.lang { String_=String, Iterable_=Iterable }
import java.util { Iterator_=Iterator, ArrayList_=ArrayList }
import io.vertx.ceylon.interop { JavaBridge { getFieldValue } }

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

"Convert a Vert.x MultiMap to a Ceylon map"
shared Map<String, [String+]> toMap(MultiMap multiMap) {
    HashMap<String, [String+]> map = HashMap<String, [String+]>();
    value keyIterator = multiMap.names().iterator();
    while (keyIterator.hasNext()) {
        value nextKey = keyIterator.next();
        String key = nextKey.string;

        // Recurse to build the values in correct order 
        [String+] read(Iterator_<String_> i) {
            value val = i.next().string;
            if (i.hasNext()) {
                return [ val, *read(i) ];
            } else {
                return [ val ];
            }
        }
        value values = read(multiMap.getAll(key).iterator());
        map.put(key, values);
    }
    return map;
}

"Convert a ceylon.json.Object to a Vert.x JsonObject"
shared JsonObject fromObject(Object obj) {
    JsonObject o = JsonObject();
    for (field in obj) {
        value val = field.item;
        switch (val)
        case (is String) { o.putString(field.key, val); }
        case (is Object) { o.putObject(field.key, fromObject(val)); }
        case (is Array) { o.putArray(field.key, fromArray(val)); }
        else { throw Exception("todo"); }
    }
    return o;
}

"Convert a ceylon.json.Array to a Vert.x JsonArray"
shared JsonArray fromArray(Array array) {
    JsonArray jsonArray = JsonArray();
    for (jsonElement in array) {
        switch (jsonElement)
        case (is String) { jsonArray.addString(jsonElement); }
        case (is Object) { jsonArray.addObject(fromObject(jsonElement)); }
        case (is Array) { jsonArray.addArray(fromArray(jsonElement)); }
        else { throw Exception("todo"); }
    }
    return jsonArray;
}

"Convert a Vert.x JsonObject to a ceylon.json.Object"
shared Object toObject(JsonObject jsonObject) {
    value obj = Object();
    value iterator = jsonObject.fieldNames.iterator();
    while (iterator.hasNext()) {
        value next = iterator.next();
        String fieldName = next.string;
        value fieldValue = getFieldValue(jsonObject, fieldName);
        switch (fieldValue)
        case (is String_) { obj.put(fieldName, fieldValue.string); }
        case (is JsonObject) { obj.put(fieldName, toObject(fieldValue)); }
        case (is JsonArray) { obj.put(fieldName, toArray(fieldValue)); }
        else { throw Exception("todo"); }
    }
    return obj;
}

"Convert a Vert.x JsonArray to a ceylon.json.Array"
shared Array toArray(JsonArray jsonArray) {
    value array = Array();
    if (jsonArray.size() > 0) {
        value iterator = jsonArray.iterator();
        while (iterator.hasNext()) {
            value element = iterator.next();
            switch(element) 
            case (is String_) { array.add(element.string); }
            case (is JsonObject) { array.add(toObject(element)); }
            case (is JsonArray) { array.add(toArray(element)); }
            else { throw Exception("todo"); }
        }
    }
    return array;
}

shared Iterable_<String_> toIterableStrings({String*} strings) {
    ArrayList_<String_> list = ArrayList_<String_>();
    for (element in strings) {
        list.add(String_(element));
    }
    return list;
}

