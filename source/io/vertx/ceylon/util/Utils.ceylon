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
import ceylon.json { Object }
import org.vertx.java.core { MultiMap }
import org.vertx.java.core.json { JsonObject }
import java.lang { String_=String }
import java.util { Iterator_=Iterator }
import io.vertx.ceylon.interop { JavaBridge { getFieldValue } }

by("Julien Viet")
shared HashMap<String, {String+}> combine(
        Map<String, {String+}> src,
        HashMap<String,
        {String+}> dst = HashMap<String, {String+}>()) {

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

"Convert a Vert.x MultiMap to a Ceylon map"
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

"Convert a ceylon.json.Object to a Vert.x JsonObject"
shared JsonObject fromObject(Object obj) {
    JsonObject jsonObject = JsonObject();
    for (field in obj) {
        value v = field.item;

        switch (v)
        case (is String) { jsonObject.putString(field.key, v); }
        case (is Object) { jsonObject.putObject(field.key, fromObject(v)); }
        else { throw Exception("todo"); }
    }
    return jsonObject;
}

"Convert a Vert.x JsonObject to a ceylon.json.Object"
shared Object toObject(JsonObject jsonObject) {
    value obj = Object();
    value fieldNameIterator = jsonObject.fieldNames.iterator();
    while (fieldNameIterator.hasNext()) {
        value nextFieldName = fieldNameIterator.next();
        String fieldName = nextFieldName.string;
        value fieldValue = getFieldValue(jsonObject, fieldName);
        
        switch (fieldValue)
        case (is JsonObject) { obj.put(fieldName, toObject(fieldValue)); }
        case (is String_) { obj.put(fieldName, fieldValue.string); }
        else { throw Exception(); }
        
    }
    
    return obj;
}


