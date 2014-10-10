import org.vertx.java.core {
  Handler_=Handler
}

shared class FunctionalHandlerAdapter<Event,AdaptedEvent>(Event adapter(AdaptedEvent event), void handler(Event event))
    satisfies Handler_<AdaptedEvent> {
  
  shared actual void handle(AdaptedEvent? adaptedEvent) {
    assert (exists adaptedEvent);
    value event = adapter(adaptedEvent);
    handler(event);
  }
}

shared Handler_<Event> functionalHandler<Event>(void handle(Event event)) {
  return FunctionalHandlerAdapter<Event,Event>(
    (Event event) => event,
    handle
  );
}
