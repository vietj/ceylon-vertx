import ceylon.test { ... }
import io.vertx.ceylon.core.shareddata { ... }
import java.lang { ByteArray }
import test.io.vertx.ceylon.core { toByteArray, byteArrayEquals, with, sharedData }

shared test void testSharedMapInteger() => with(sharedData(testMap(0, 4, (Integer item1, Integer item2) => item1.equals(item2))));
shared test void testSharedMapString() => with(sharedData(testMap("foo", "bar", (String item1, String item2) => item1.equals(item2))));
shared test void testSharedMapFloat() => with(sharedData(testMap(0.4, 0.5, (Float item1, Float item2) => item1.equals(item2))));
shared test void testSharedMapBoolean() => with(sharedData(testMap(true, false, (Boolean item1, Boolean item2) => item1.equals(item2))));
shared test void testSharedMapByteArray() => with(sharedData(testMap(toByteArray({0,1,2}), toByteArray({2,1,0}), byteArrayEquals)));

shared test void testSharedSetInteger() => with(sharedData(testSet(0, (Integer item1, Integer item2) => item1.equals(item2))));
shared test void testSharedSetString() => with(sharedData(testSet("foo", (String item1, String item2) => item1.equals(item2))));
shared test void testSharedSetFloat() => with(sharedData(testSet(0.4, (Float item1, Float item2) => item1.equals(item2))));
shared test void testSharedSetBoolean() => with(sharedData(testSet(true, (Boolean item1, Boolean item2) => item1.equals(item2))));
shared test void testSharedSetByteArray() => with(sharedData(testSet(toByteArray({0,1,2}), byteArrayEquals)));

void testMap<Key, Item>(Key key, Item item, Boolean compare(Item item1, Item item2))(SharedData sharedData)
        given Key of Integer|String|Boolean|Float|Character|ByteArray satisfies Object
        given Item of Integer|String|Boolean|Float|Character|ByteArray satisfies Object {
    value m = sharedData.getMap<Key, Item>("m");
    
    // Contains
    assertFalse(m.contains(key));
    
    // Put
    m.put(key, item);
    
    // Get
    Item? actual = m.get(key);
    if (exists actual) {
        if (!compare(actual, item)) {
            // Produce a nice message
            assertEquals(actual, item);
        }
    } else {
        fail("Was not expecting value to be null");
    }
    
    // Contains
    assertTrue(m.contains(key));
    
    // Iterate
    value i = m.iterator();
    assert(is Key->Item next = i.next());
    if (!compare(next.item, item)) {
        // Produce a nice message
        assertEquals(actual, item);
    }
    assertEquals(finished, i.next());

    // Remove
    Item? removed = m.remove(key);
    if (exists removed) {
        if (!compare(item, removed)) {
            // Produce a nice message
            assertEquals(actual, item);
        }
    } else {
        fail("Was not expecting value to be null");
    }
    
    // Contains
    assertFalse(m.contains(key));
}

void testSet<Element>(Element element, Boolean compare(Element element1, Element element2))(SharedData sharedData)
        given Element of Integer|String|Boolean|Float|Character|ByteArray satisfies Object {
    value m = sharedData.getSet<Element>("m");
    assertFalse(m.contains(element));
    assertTrue(m.add(element));
    assertTrue(m.contains(element));
    value i = m.iterator();
    assert(is Element next = i.next());
    if (!compare(next, element)) {
        // Produce a nice message
        assertEquals(next, element);
    }
    assertEquals(finished, i.next());
    assertTrue(m.remove(element));
    assertFalse(m.contains(element));
}