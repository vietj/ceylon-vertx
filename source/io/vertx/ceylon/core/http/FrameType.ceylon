"""List of all frame types."""
shared abstract class FrameType() of continuationFrame | textFrame | binaryFrame | closeFrame | pingFrame | pongFrame {
}

shared object continuationFrame extends FrameType() {}
shared object textFrame extends FrameType() {}
shared object binaryFrame extends FrameType() {}
shared object closeFrame extends FrameType() {}
shared object pingFrame extends FrameType() {}
shared object pongFrame extends FrameType() {}
