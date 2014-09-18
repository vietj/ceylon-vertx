import ceylon.time {
  DateTime
}

"""Represents properties of a file on the file system.
   
   Instances of FileProps are thread-safe"""
shared class FileProps(
  "The date the file was created"
  shared DateTime creationTime,
  "The date the file was last accessed"
  shared DateTime lastAccessTime,
  "The date the file was last modified"
  shared DateTime lastModifiedTime,
  "Is the file a directory?"
  shared Boolean directory,
  "Is the file some other type? (I.e. not a directory, regular file or symbolic link)"
  shared Boolean other,
  "Is the file a regular file?"
  shared Boolean regularFile,
  "Is the file a symbolic link?"
  shared Boolean symbolicLink,
  "The size of the file, in bytes"
  shared Integer size) {
}