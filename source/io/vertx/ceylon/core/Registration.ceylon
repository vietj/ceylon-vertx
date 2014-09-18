import ceylon.promise { Promise }

"A registration, the `completed` promise is resolved when the registration is completed, the `cancel()` method
 can be used to cancel the registration."
by("Julien Viet")
shared interface Registration {

    "Resolved when the registration is complete"
    shared formal Promise<Null> completed;

    "Cancel the registration, this is an asynchronous operation."
    shared formal Promise<Null> cancel();

}
