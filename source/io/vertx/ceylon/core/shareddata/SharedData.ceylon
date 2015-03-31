import org.vertx.java.core.shareddata {
  SharedData_=SharedData
}
import java.lang {
  ByteArray,
  Long_=Long,
  Double_=Double,
  Boolean_=Boolean,
  String_=String
}

Long_ wrapInteger(Integer v) => Long_(v);
Integer unwrapInteger(Long_ v) => v.longValue();
Boolean_ wrapBoolean(Boolean v) => Boolean_(v);
Boolean unwrapBoolean(Boolean_ v) => v.booleanValue();
Double_ wrapFloat(Float v) => Double_(v);
Float unwrapFloat(Double_ v) => v.doubleValue();
String_ wrapString(String v) => String_(v);
String(String_) unwrapString = String_.string;
ByteArray(ByteArray) wrapByteArray = (ByteArray arg) => arg;
ByteArray(ByteArray) unwrapByteArray = wrapByteArray;

"""Sometimes it is desirable to share immutable data between different event loops, for example to implement a
   cache of data.
   
   This class allows instances of shared data structures to be looked up and used from different event loops.
   
   The data structures themselves will only allow certain data types to be stored into them. This shields you from
   worrying about any thread safety issues might occur if mutable objects were shared between event loops.
   
   The following types can be stored in a shareddata data structure:
   
   * [[Integer]]
   * [[String]]
   * [[Float]]
   * [[Boolean]]
   * java.lang.ByteArray - this will be automatically copied, and the copy will be stored in the structure
   
   Instances of this class are thread-safe."""
shared class SharedData(SharedData_ delegate) {
  
  """Return a [[SharedMap]] with the specific [[name]]. All invocations of this method with the same value
     of [[name]] are guaranteed to return the same [[SharedMap]] instance."""
  shared SharedMap<Key,Item> getMap<Key,Item>(String name)
      given Key of Integer | String | Boolean | Float | Character | ByteArray satisfies Object
      given Item of Integer | String | Boolean | Float | Character | ByteArray satisfies Object {
    if (`Key` == `Integer`) {
      value ret = createMapForKey<Integer,Long_,Item>(wrapInteger, unwrapInteger, name);
      assert (is SharedMap<Key,Item> ret);
      return ret;
    } else if (`Key` == `Boolean`) {
      value ret = createMapForKey<Boolean,Boolean_,Item>(wrapBoolean, unwrapBoolean, name);
      assert (is SharedMap<Key,Item> ret);
      return ret;
    } else if (`Key` == `Float`) {
      value ret = createMapForKey<Float,Double_,Item>(wrapFloat, unwrapFloat, name);
      assert (is SharedMap<Key,Item> ret);
      return ret;
    } else if (`Key` == `String`) {
      value ret = createMapForKey<String,String_,Item>(wrapString, unwrapString, name);
      assert (is SharedMap<Key,Item> ret);
      return ret;
    } else if (`Key` == `ByteArray`) {
      value ret = createMapForKey<ByteArray,ByteArray,Item>(wrapByteArray, unwrapByteArray, name);
      assert (is SharedMap<Key,Item> ret);
      return ret;
    } else {
      throw Exception("Not possible");
    }
  }
  
  SharedMap<ExtKey,Item> createMapForKey<ExtKey,IntKey,Item>(IntKey(ExtKey) keyWrapper, ExtKey(IntKey) keyUnwrapper, String name)
      given IntKey satisfies Object
      given ExtKey satisfies Object
      given Item satisfies Object {
    if (`Item` == `Integer`) {
      value ret = createMapForKeyAndItem(keyWrapper, keyUnwrapper, wrapInteger, unwrapInteger, name);
      assert (is SharedMap<ExtKey,Item> ret);
      return ret;
    } else if (`Item` == `Boolean`) {
      value ret = createMapForKeyAndItem(keyWrapper, keyUnwrapper, wrapBoolean, unwrapBoolean, name);
      assert (is SharedMap<ExtKey,Item> ret);
      return ret;
    } else if (`Item` == `Float`) {
      value ret = createMapForKeyAndItem(keyWrapper, keyUnwrapper, wrapFloat, unwrapFloat, name);
      assert (is SharedMap<ExtKey,Item> ret);
      return ret;
    } else if (`Item` == `String`) {
      value ret = createMapForKeyAndItem(keyWrapper, keyUnwrapper, wrapString, unwrapString, name);
      assert (is SharedMap<ExtKey,Item> ret);
      return ret;
    } else if (`Item` == `ByteArray`) {
      value ret = createMapForKeyAndItem(keyWrapper, keyUnwrapper, wrapByteArray, unwrapByteArray, name);
      assert (is SharedMap<ExtKey,Item> ret);
      return ret;
    } else {
      throw Exception("Not possible");
    }
  }
  
  SharedMap<ExtKey,ExtItem> createMapForKeyAndItem<ExtKey,IntKey,ExtItem,IntItem>(
    IntKey(ExtKey) keyWrapper,
    ExtKey(IntKey) keyUnwrapper,
    IntItem(ExtItem) itemWrapper,
    ExtItem(IntItem) itemUnwrapper,
    String name)
      given IntKey satisfies Object
      given ExtKey satisfies Object
      given IntItem satisfies Object
      given ExtItem satisfies Object {
    value map = delegate.getMap<IntKey,IntItem>(name);
    return InternalSharedMap(map, keyWrapper, keyUnwrapper, itemWrapper, itemUnwrapper);
  }
  
  """Return a [[SharedSet]] with the specific [[name]]. All invocations of this method with the same value
     of [[name]] are guaranteed to return the same [[SharedSet]] instance."""
  shared SharedSet<Element> getSet<Element>(String name)
      given Element of Integer | String | Boolean | Float | Character | ByteArray satisfies Object {
    if (`Element` == `Integer`) {
      value ret = createSetForElement<Integer,Long_>(wrapInteger, unwrapInteger, name);
      assert (is SharedSet<Element> ret);
      return ret;
    } else if (`Element` == `Boolean`) {
      value ret = createSetForElement<Boolean,Boolean_>(wrapBoolean, unwrapBoolean, name);
      assert (is SharedSet<Element> ret);
      return ret;
    } else if (`Element` == `Float`) {
      value ret = createSetForElement<Float,Double_>(wrapFloat, unwrapFloat, name);
      assert (is SharedSet<Element> ret);
      return ret;
    } else if (`Element` == `String`) {
      value ret = createSetForElement<String,String_>(wrapString, unwrapString, name);
      assert (is SharedSet<Element> ret);
      return ret;
    } else if (`Element` == `ByteArray`) {
      value ret = createSetForElement<ByteArray,ByteArray>(wrapByteArray, unwrapByteArray, name);
      assert (is SharedSet<Element> ret);
      return ret;
    } else {
      throw Exception("Not possible");
    }
  }
  
  SharedSet<ExtElement> createSetForElement<ExtElement,IntElement>(
    IntElement(ExtElement) keyWrapper,
    ExtElement(IntElement) keyUnwrapper,
    String name)
      given IntElement satisfies Object
      given ExtElement satisfies Object {
    value map = delegate.getSet<IntElement>(name);
    return InternalSharedSet(map, keyWrapper, keyUnwrapper);
  }
  
  "Remove the map with the specific [[name]]."
  shared Boolean removeMap(String name) {
    return delegate.removeMap(name);
  }
  
  "Remove the set with the specific [[name]]."
  shared Boolean removeSet(String name) {
    return delegate.removeSet(name);
  }
}
