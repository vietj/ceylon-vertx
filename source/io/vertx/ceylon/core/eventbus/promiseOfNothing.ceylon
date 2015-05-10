import ceylon.promise {
  Promise,
  ExecutionContext
}

"A promise of nothing always rejected"
by ("Julien Viet")
object promiseOfNothing extends Promise<Nothing>() {
  
  shared actual Promise<Result> flatMap<Result>(Promise<Result>(Nothing) onFulfilled, Promise<Result>(Throwable) onRejected) {
    throw Exception();
    /*
    try {
      return onRejected(Exception("No result expected"));
    } catch (Exception e) {
      return promiseOfNothing;
    }
     */
  }
  shared actual Promise<Result> map<Result>(Result(Nothing) onFulfilled, Result(Throwable) onRejected) {
    throw Exception();
  }
  
  shared actual ExecutionContext context => nothing;
  
}
