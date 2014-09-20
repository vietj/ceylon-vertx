import java.lang { ByteArray }

shared Boolean byteArrayEquals(ByteArray ba1, ByteArray ba2) {
  if (ba1.size == ba2.size) {
    for (i in 0..ba1.size-1) {
      if (ba1.get(i) != ba2.get(i)) {
        return false;
      }
    }
    return true;
  } else {
    return false;
  }
}
