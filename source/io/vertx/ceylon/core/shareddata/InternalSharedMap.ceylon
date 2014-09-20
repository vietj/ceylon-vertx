import org.vertx.java.core.shareddata { ConcurrentSharedMap_ = ConcurrentSharedMap }
import java.util { Map_ = Map }
import java.lang { ByteArray }
import io.vertx.ceylon.core.util {
  byteArrayEquals
}

class InternalSharedMap<ExtKey, ExtItem, IntKey, IntItem>(
        shared ConcurrentSharedMap_<IntKey, IntItem> delegate,
        IntKey wrapKey(ExtKey key),
        ExtKey unwrapKey(IntKey key),
        IntItem wrapItem(ExtItem item),
        ExtItem unwrapItem(IntItem item)
    ) satisfies SharedMap<ExtKey, ExtItem>
    given ExtKey satisfies Object
    given ExtItem satisfies Object
    given IntKey satisfies Object
    given IntItem satisfies Object
    {

    shared actual Anything clear() => delegate.clear();
    
    shared actual ExtItem? get(Object key) {
        if (is ExtKey key) {
            value wrappedKey = wrapKey(key);
            IntItem? wrappedItem = delegate.get(wrappedKey);
            if (exists wrappedItem) {
                return unwrapItem(wrappedItem);
            }
        }
        return null;
    }
    
    shared actual Boolean defines(Object key) {
        if (is ExtKey key) {
            value wrappedKey = wrapKey(key);
            return delegate.containsKey(wrappedKey);
        }
        return false;
    }

    shared actual Boolean contains(Object entry) {
        if (is ExtKey->ExtItem entry) {
            value wrappedKey = wrapKey(entry.key);
            IntItem? wrappedItem = delegate.get(wrappedKey);
            if (exists wrappedItem) {
              value item = unwrapItem(wrappedItem);
              if (is ByteArray item) {
                assert(is ByteArray tmp = entry.item);
                return byteArrayEquals(tmp, item);
              } else if (entry.item == unwrapItem(wrappedItem)) {
                return true;
              }
            }
        }
        return false;
    }

    shared actual Iterator<ExtKey->ExtItem> iterator() {
        value d = delegate.entrySet().iterator();
        object i satisfies Iterator<ExtKey->ExtItem> {
            shared actual <ExtKey->ExtItem>|Finished next() {
                if (d.hasNext()) {
                    value next = d.next();
                    value key = unwrapKey(next.key);
                    value item = unwrapItem(next.\ivalue);
                    return key->item;
                } else {
                    return finished;
                }
            }
        }
        return i;
    }
    
    shared actual ExtItem? put(ExtKey key, ExtItem item) {
        value wrappedKey = wrapKey(key);
        value wrappedItem = wrapItem(item);
        IntItem? previous = delegate.put(wrappedKey, wrappedItem);
        if (exists previous) {
            return unwrapItem(previous);
        } else {
            return null;
        }
    }
    
    shared actual ExtItem? putIfAbsent(ExtKey key, ExtItem item) {
        value wrappedKey = wrapKey(key);
        value wrappedItem = wrapItem(item);
        IntItem? previous = delegate.putIfAbsent(wrappedKey, wrappedItem);
        if (exists previous) {
            return unwrapItem(previous);
        } else {
            return null;
        }
    }
    
    shared actual ExtItem? remove(ExtKey key) {
        value wrappedKey = wrapKey(key);
        Map_<IntKey, IntItem> tmp = delegate; // Need this cast otherwise it is fooled by remove(Object,Object)
        IntItem? previous = tmp.remove(wrappedKey);
        if (exists previous) {
            return unwrapItem(previous);
        } else {
            return null;
        }
    }
    
    shared actual Boolean removeIfEquals(ExtKey key, ExtItem item) {
        value wrappedKey = wrapKey(key);
        value wrappedItem = wrapItem(item);
        return delegate.remove(wrappedKey, wrappedItem);
    }
    
    shared actual Boolean replaceIfPresent(ExtKey key, ExtItem oldItem, ExtItem newItem) {
        value wrappedKey = wrapKey(key);
        value wrappedOldItem = wrapItem(oldItem);
        value wrappedNewItem = wrapItem(newItem);
        return delegate.replace(wrappedKey, wrappedOldItem, wrappedNewItem);
    }
    
    shared actual Boolean equals(Object that) {
        if (is InternalSharedMap<ExtKey, ExtItem, IntKey, IntItem> that) {
            return delegate.equals(that.delegate);
        } else {
            return false;
        }
    }
    
    shared actual Integer hash => delegate.hash;

}
