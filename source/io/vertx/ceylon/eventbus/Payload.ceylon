import ceylon.json { JSonArray=Array, JSonObject=Object }
import java.lang { ByteArray }

"Alias for the type of a message payload"
shared alias Payload => String|JSonObject|JSonArray|Integer|Float|Boolean|ByteArray;

