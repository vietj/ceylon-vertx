import ceylon.promise { ExecutionContext }

shared object testContext satisfies ExecutionContext {
  shared actual void run(void task()) {
    task();
  }
  shared actual ExecutionContext childContext() => this;  
}
