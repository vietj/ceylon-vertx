import org.vertx.java.core.buffer { Buffer }
import ceylon.test { ... }
import java.lang { ByteArray }

shared test void testEmptyBuffer() {
  value buff = Buffer();
}

shared test void testStringBuffer() {
  value buff = Buffer("some-string");
}

shared test void testStringEncodedBuffer() {
  value buff = Buffer("some-string", "UTF-8");
}

shared test void testByteArrayBuffer() {
  value bytes = ByteArray(5);
  bytes.set(0, 65.byte);
  bytes.set(0, 66.byte);
  bytes.set(0, 67.byte);
  bytes.set(0, 68.byte);
  bytes.set(0, 69.byte);
  value buff = Buffer(bytes);
}

shared test void testInitialSizeBuffer() {
  value buff = Buffer(100000);
}

shared test void testBufferAppend() {
  value buff = Buffer();
  buff.appendInt(123).appendString("hello\n");
}

shared test void testBufferRandomAccess() {
  value buff = Buffer();
  buff.setInt(1000, 123);
  buff.setString(0, "hello");
}

shared test void testBufferRead() {
  value buff = Buffer();
  buff.setInt(0, 3);
  Integer i = buff.getInt(0);
}