import java.util {
  Set_=Set
}

class InternalSharedSet<ExtElement,IntElement>(
  shared Set_<IntElement> delegate,
  IntElement wrapElement(ExtElement element),
  ExtElement unwrapElement(IntElement element))
    satisfies SharedSet<ExtElement>
    given IntElement satisfies Object
    given ExtElement satisfies Object {
  
  shared actual Boolean add(ExtElement element) {
    value wrappedElement = wrapElement(element);
    return delegate.add(wrappedElement);
  }
  
  shared actual void clear() => delegate.clear();
  
  shared actual Iterator<ExtElement> iterator() {
    value d = delegate.iterator();
    object i satisfies Iterator<ExtElement> {
      shared actual <ExtElement>|Finished next() {
        if (d.hasNext()) {
          value next = d.next();
          return unwrapElement(next);
        } else {
          return finished;
        }
      }
    }
    return i;
  }
  
  shared actual Boolean contains(Object key) {
    if (is ExtElement key) {
      value wrappedElement = wrapElement(key);
      return delegate.contains(wrappedElement);
    }
    return false;
  }
  
  shared actual Boolean remove(ExtElement element) {
    value wrappedElement = wrapElement(element);
    return delegate.remove(wrappedElement);
  }
}
