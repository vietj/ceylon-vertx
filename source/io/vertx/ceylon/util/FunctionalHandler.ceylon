import org.vertx.java.core { Handler_=Handler }

shared class FunctionalHandler<Event, AdaptedEvent>(Event adapter(AdaptedEvent event), void handler(Event event))
    satisfies Handler_<AdaptedEvent> {

  shared actual void handle(AdaptedEvent? adaptedEvent) {
    assert(exists adaptedEvent);
    value event = adapter(adaptedEvent);
    handler(event);
  }
}