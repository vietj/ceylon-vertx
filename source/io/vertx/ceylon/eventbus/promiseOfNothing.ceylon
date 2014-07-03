import ceylon.promise { Promise }

"A promise of nothing always rejected"
by("Julien Viet")
object promiseOfNothing extends Promise<Nothing>() {
	
	shared actual Promise<Result> handle<Result>(Promise<Result>(Nothing) onFulfilled, Promise<Result>(Throwable) onRejected) {
		try {
			return onRejected(Exception("No result expected"));
		} catch(Exception e) {
			return promiseOfNothing;
		}
	}
}
