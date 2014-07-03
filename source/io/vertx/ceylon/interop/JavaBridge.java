package io.vertx.ceylon.interop;

import org.vertx.java.core.json.JsonObject;

public class JavaBridge {

  // Erase the <T> variable from getField 
  public static Object getFieldValue(JsonObject obj, String fieldName) {
    return obj.getField(fieldName);
  }
  
}
