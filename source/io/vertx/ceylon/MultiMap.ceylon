import org.vertx.java.core { MultiMap_=MultiMap }
import java.lang { String_=String }
import java.util { Iterator_=Iterator, List_=List }

shared class MultiMap(MultiMap_ delegate) satisfies Map<String, [String+]> {

  [String+] read(Iterator_<String_> i) {
    value val = i.next().string;
    if (i.hasNext()) {
      return [ val, *read(i) ];
    } else {
      return [ val ];
    }
  }

  // Not needed at the moment
  shared actual Map<String,[String+]> clone() => this;
  
  shared actual Boolean defines(Object key) {
    if (is String key) {
      return delegate.contains(key);
    }
    return false;
  }

  shared actual [String+]? get(Object key) {
    if (is String key) {
      List_<String_>? val = delegate.getAll(key);
      if (exists val) {
        return read(val.iterator());
      }
    }
    return null;
  }
  
  shared actual Iterator<String->[String+]> iterator() {
    value i = delegate.names().iterator();
    object it satisfies Iterator<String->[String+]> {      
      shared actual <String->[String+]>|Finished next() {
        if (i.hasNext()) {
          value name = i.next().string;
          assert(exists val = get(name));
          return name->val;
        } else {
          return finished;
        }
      }
    }    
    return it;
  }
  
  shared actual Boolean equals(Object that) => (super of Map<String, [String+]>).equals(that);
  
  shared actual Integer hash => (super of Map<String, [String+]>).hash;
}
