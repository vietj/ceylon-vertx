"""Represents properties of the file system.
   
   Instances of FileSystemProps are thread-safe."""
shared class FileSystemProps(
  "The total space on the file system, in bytes"
  shared Integer totalSpace,
  "The total un-allocated space on the file system, in bytes"
  shared Integer unallocatedSpace,
  "The total usable space on the file system, in bytes"
  shared Integer usableSpace) {}
