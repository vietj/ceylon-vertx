import ceylon.promise {
  Deferred,
  ExecutionContext
}

by ("Julien Viet")
class MessageAdapter<M>(ExecutionContext context) extends AbstractMessageAdapter<M>(context) {
  
  "The deferred for the reply"
  shared Deferred<Message<M>> deferred = Deferred<Message<M>>(context);
  
  shared actual void dispatch(Message<M> message) {
    deferred.fulfill(message);
  }
  
  shared actual void reject(Object? body) {
    if (exists body) {
      deferred.reject(Exception("Wrong promise type for reply ``body``"));
    } else {
      deferred.reject(Exception("Wrong promise type for null reply"));
    }
  }
}
