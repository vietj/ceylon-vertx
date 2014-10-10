"""A shared set, this class does not use [[ceylon.collection::MutableSet]] at the moment to remain compatible between
   Ceylon 1.0 and 1.1."""
shared interface SharedSet<Element> satisfies {Element*}
    given Element satisfies Object {
  
  "Add an element to this set, returning true if the element
   was already a member of the set, or false otherwise."
  shared formal Boolean add(Element element);
  
  "Remove an element from this set, returning true if the
   element was previously a member of the set."
  shared formal Boolean remove(Element element);
  
  "Remove every element from this set, leaving an empty set."
  shared formal void clear();
}
