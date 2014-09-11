import ceylon.json { JSonArray=Array, JSonObject=Object }
import java.lang { ByteArray }
import org.vertx.java.core.buffer { Buffer_=Buffer }

"Alias for the type of a message payload"
shared alias Payload => String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray|Byte|Character|Buffer_|Null;

