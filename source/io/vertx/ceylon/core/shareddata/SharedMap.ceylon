"""A shared map, this class does not use [[ceylon.collection::MutableMap]] at the moment to remain compatible between
   Ceylon 1.0 and 1.1.
   
   SharedMap has very similar semantics as ConcurrentMap with the difference that any updates made to
   the collections returned from keySet, valueSet and entrySet methods do not change the keys and values in the
   underlying Map.
   
   This is because the Map can contain mutable data such as Buffer and byte[] objects so we must copy such elements
   before they are returned to you. This prevents a situation where the same entry entry is being updated
   concurrently by more than one thread, which could lead to race conditions."""
shared interface SharedMap<Key, Item> satisfies Correspondence<Object, Item> & {<Key->Item>*}
        given Key satisfies Object
        given Item satisfies Object {
    
    "Remove every entry from this map, leaving an empty map."
    shared formal void clear();

    "Remove the entry associated with the given `key`, if any, from 
     this map, returning the value no longer associated with the 
     given `key`, if any, or null."
    shared formal Item? remove(Key key);

    "Add an entry to this map, overwriting any existing entry for 
     the given `key`, and returning the previous value associated 
     with the given `key`, if any, or null."
    shared formal Item? put(Key key, Item item);

    "Same operation than [[java.util.concurrent::ConcurrentHashMap.putIfAbsent]]"
    shared formal Item? putIfAbsent(Key key, Item item);
    
    "Same operation than [[java.util.concurrent::ConcurrentHashMap.remove]]"
    shared formal Boolean removeIfEquals(Key key, Item item);
    
    "Same operation than [[java.util.concurrent::ConcurrentHashMap.replace]]"
    shared formal Boolean replaceIfPresent(Key key, Item oldItem, Item newItem);
    
}