"""Represents the version of the WebSockets specification"""
shared abstract class WebSocketVersion() of \iHYBI_00 | \iHYBI_08 | \iRFC6455 {}

shared object \iHYBI_00 extends WebSocketVersion() {}
shared object \iHYBI_08 extends WebSocketVersion() {}
shared object \iRFC6455 extends WebSocketVersion() {}