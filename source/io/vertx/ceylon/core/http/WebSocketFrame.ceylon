import org.vertx.java.core.http {
  WebSocketFrame_=WebSocketFrame {
    FrameType_=FrameType
  }
}

"""A Web Socket frame that represents either text or binary data."""
shared class WebSocketFrame(WebSocketFrame_ delegate) {
  
  shared FrameType type;
  
  if (delegate.type() == FrameType_.\iCONTINUATION) {
    type = continuationFrame;
  } else if (delegate.type() == FrameType_.\iTEXT) {
    type = textFrame;
  } else if (delegate.type() == FrameType_.\iBINARY) {
    type = binaryFrame;
  } else if (delegate.type() == FrameType_.\iCLOSE) {
    type = closeFrame;
  } else if (delegate.type() == FrameType_.\iPING) {
    type = pingFrame;
  } else {
    type = pongFrame;
  }
  
  """Returns `true` if and only if the content of this frame is a string encoded in UTF-8."""
  shared Boolean text = delegate.text;
  
  """Returns `true` if and only if the content of this frame is an arbitrary binary data."""
  shared Boolean binary = delegate.binary;
  
  """Converts the content of this frame into a UTF-8 string and returns the
     converted string."""
  shared String textData => delegate.textData();
  
  """Returns the string representation of this frame.  Please note that this
     method is not identical to [[textData]]."""
  shared actual String string => delegate.string;
  
  """Returns `true` if this is the final frame.  This should be true unless a number of 
     continuation frames are expected to follow this frame."""
  shared Boolean finalFrame = delegate.finalFrame;
}
