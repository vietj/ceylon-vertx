"""# File System
   
   Vert.x lets you manipulate files on the file system. File system operations are asynchronous and returns a
   promise. This promise will be resolved when the operation is complete, or
   an error has occurred.
   
   ## Synchronous forms
   
   For convenience, we also provide synchronous forms of most operations. It's highly recommended the asynchronous
   forms are always used for real applications.
   
   The synchronous form does not take a handler as an argument and returns its results directly. The name
   of the synchronous function is the same as the name as the asynchronous form with `Sync` appended.
   
   ## copy
   
   Copies a file.
   
   This function can be called in two different ways:
   
   `copy(source, destination)`
   
   Non recursive file copy. source is the source file name. destination is the destination file name. Here's an example:
   
   ~~~
   value promise = vertx.fileSystem.copy("foo.dat", "bar.dat");
   promise.onComplete(
      (Null n) => print("Copy was successful"),
      (Throwable t) => print("Failed to copy``t``")
   );
   ~~~
   
   `copy(source, destination, recursive)`

   Recursive copy. source is the source file name. destination is the destination file name. `recursive` is a
   boolean flag - if true and source is a directory, then a recursive copy of the directory and all its
   contents will be attempted.
   
   ## move
   
   Moves a file.
   
   `move(source, destination, handler)`
   
   `source is the source file name. `destination` is the destination file name.
   
   ## truncate
   
   Truncates a file.
   
   `truncate(file, len, handler)`
   
   `file` is the file name of the file to truncate. `len` is the length in bytes to truncate it to.
   
   ## chmod
   
   Changes permissions on a file or directory. This function can be called in two different ways:
   
   `chmod(file, perms)`
   
   Change permissions on a file.
   
   `file` is the file name. `perms` is a Unix style permissions string made up of 9 characters. The first three
   are the owner's permissions. The second three are the group's permissions and the third three are
   others permissions. In each group of three if the first character is `r` then it represents a read permission.
   If the second character is `w` it represents write permission. If the third character is `x` it represents
   execute permission. If the entity does not have the permission the letter is replaced with `-`. Some examples:
   
   ~~~
   rwxr-xr-x
   r--r--r--
   ~~~
   
   `chmod(file, perms, dirPerms)`
   
   Recursively change permissions on a directory. `file` is the directory name. `perms` is a Unix style permissions
   to apply recursively to any files in the directory. `dirPerms` is a Unix style permissions string to apply to the directory and any other child directories recursively.
   
   ## props
   
   Retrieve properties of a file.
   
   `props(file)`
   
   `file is the file name. The props are returned in the handler. The results is an object with the following methods:
   
   - [[FileProps.creationTime]]: Time of file creation.
   - [[FileProps.lastAccessTime]]: Time of last file access.
   - [[FileProps.lastModifiedTime]]: Time file was last modified.
   - [[FileProps.directory]]: This will have the value true if the file is a directory.
   - [[FileProps.regularFile]]: This will have the value `true` if the file is a regular file (not symlink or directory).
   - [[FileProps.symbolicLink]]: This will have the value `true` if the file is a symbolic link.
   - [[FileProps.other]]: This will have the value `true` if the file is another type.
   
   Here's an example:
   
   ~~~
   value promise = vertx.fileSystem.props("foo.dat");
   promise.onComplete(
     (FileProps props) => print("Last accessed: `props.lastAccessTime`"),
     (Throwable err) => print("Failed to get props ``err`")
   );
   ~~~
   
   ## lprops
   
   Retrieve properties of a link. This is like [[FileSystem.props]] but should be used when you want to retrieve properties of a
   link itself without following it.
   
   It takes the same arguments and provides the same results as [[FileSystem.props]].
   
   ## link
   
   Create a hard link.
   
   `link(link, existing)`
   
   `link` is the name of the link. `existing` is the existing file (i.e. where to point the link at).
   
   ## symlink
   
   Create a symbolic link.
   
   `symlink(link, existing)`
   
   `link` is the name of the symlink. `existing` is the exsting file (i.e. where to point the symlink at).
   
   ## unlink
   
   Unlink (delete) a link.
   
   `unlink(link)`
   
   `link` is the name of the link to unlink.

   ## readSymLink
   
   Reads a symbolic link. I.e returns the path representing the file that the symbolic link specified by `link` points to.
   
   `readSymLink(link)`
   
   `link` is the name of the link to read. An usage example would be:

   ~~~
   value promise = vertx.fileSystem.readSymLink("somelink");
   promise.onComplete(
     (String s) => print("Link points at ``s``"),
     (Throwable err) => print("Failed to read ``err``")
   );   
   ~~~
   
   ## delete
   
   Deletes a file or recursively deletes a directory.
   
   This function can be called in two ways:
   
   `delete(file)`
   
   Deletes a file. `file` is the file name.
   
   `delete(file, recursive)`
   
   If `recursive` is `true`, it deletes a directory with name `file`, recursively. Otherwise it just deletes a file.

   ## mkdir
   
   Creates a directory.
   
   This function can be called in three ways:
   
   `mkdir(dirname)`
   
   Makes a new empty directory with name `dirname`, and default permissions `
   
   `mkdir(dirname, createParents)`
   
   If `createParents` is `true`, this creates a new directory and creates any of its parents too. Here's an example
   
   ~~~
   value promise = vertx.fileSystem.mkdir("a/b/c", true);
   promise.onComplete(
     (Null n) => print("Directory created ok"),
     (Throwable err) => print("Failed to mkdir ``err``")
   );
   ~~~
   
   `mkdir(dirname, createParents, perms)`
   
   Like `mkdir(dirname, createParents)`, but also allows permissions for the newly created director(ies) to
   be specified. `perms` is a Unix style permissions string as explained earlier.
   
   ## readDir
   
   Reads a directory. I.e. lists the contents of the directory.
   
   This function can be called in two ways:
   
   `readDir(dirName)`
   
   Lists the contents of a directory
   
   `readDir(dirName, filter)`
   List only the contents of a directory which match the filter. Here's an example which only lists files
   with an extension `txt` in a directory.
   
   ~~~
   value promise = vertx.fileSystem.readDir("mydirectory", ".*\\.txt");
   promise.onComplete(
     ({String*} names) => print("Directory contains these .txt files: ``names``"),
     (Throwable err) => print("Failed to read ``err`")
   );
   ~~~
   
   The filter is a regular expression.
   
   ## readFile
   
   Read the entire contents of a file in one go. _Be careful if using this with large files since the entire file
   will be stored in memory at once._
   
   `readFile(file)`
   
   Where `file` is the file name of the file to read.
   
   The body of the file will be provided as an instance of `org.vertx.java.core.buffer.Buffer` by the promise.
   
   Here is an example:
   
   ~~~
   value promise = vertx.fileSystem.readFile("myfile.dat");
   promise.onComplete(
     (Buffer buf) => print("File contains: ``buf.length()`` bytes"),
     (Throwable err) => print("Failed to read ``err`")
   );
   ~~~
   
   ## writeFile
   
   Writes an entire `Buffer` or a string into a new file on disk.
   
   `writeFile(file, data)`
   
   Where `file` is the file name. `data` is a `Buffer` or string.
    
   ## createFile
    
   Creates a new empty file.
   
   `createFile(file)`
   
   Where `file` is the file name.
   
   ## exists
   
   Checks if a file exists.
   
   `exists(file)`
   
   Where `file` is the file name.
   
   The result is provided by the promise.

   ~~~
   value promise = vertx.fileSystem.exists("some-file.txt");
   promise.onComplete(
     (Boolean b) => print("File " + ``b ? "exists" : "does not exist"``"),
     (Throwable err) => print("Failed to check existence ``err``")
   );
   ~~~
   
   ## fsProps
   
   Get properties for the file system.
   
   `fsProps(file)`
   
   Where `file` is any file on the file system.
   
   The result is provided by the promise. The result object is an instance of [[FileSystemProps]] has the following
   methods:
   
   - [[FileSystemProps.totalSpace]]: Total space on the file system in bytes.
   - [[FileSystemProps.unallocatedSpace]]: Unallocated space on the file system in bytes.
   - [[FileSystemProps.usableSpace]]: Usable space on the file system in bytes.
   
   Here is an example:

   ~~~
   value promise = vertx.fileSystem.fsProps("mydir");
   promise.onComplete(
     (FileSystemProps props) => print("total space: ``props.totalSpace``"),
     (Throwable err) => print("Failed to check existence ``err``")
   );
   ~~~
   
   ## open
   
   Opens an asynchronous file for reading \ writing.
   
   This function can be called in four different ways:
   
   `open(file)`
   
   Opens a file for reading and writing. `file` is the file name. It creates it if it does not already exist.
   
   `open(file, perms)`
   
   Opens a file for reading and writing. `file` is the file name. It creates it if it does not already exist and assigns
   it the permissions as specified by `perms`.
   
   `open(file, perms, createNew)`
   
   Opens a file for reading and writing. `file `is the file name. If `createNew` is `true` it creates it if
   it does not already exist.
   
   `open(file, perms, read, createNew, write)`
   
   Opens a file. `file` is the file name. If `read` is` true` it is opened for reading. If `write` is `true`
   it is opened for writing. If `createNew` is `true` it creates it if it does not already exist.
   
   `open(file, perms, read, createNew, write, flush)`
   
   Opens a file. `file` is the file name. If `read` is `true` it is opened for reading. If `write` is `true`
   it is opened for writing. If `createNew` is `true` it creates it if it does not already exist. If
   `flush` is `true` all writes are immediately flushed through the OS cache (default value of flush is `false`).
   
   When the file is opened, an instance of [[AsyncFile]] is provided by the promise:
   
   ~~~
   value promise = vertx.fileSystem.open("some-file.dat");
   promise.onComplete(
     (AsyncFile f) => print("File opened ok!"),
     (Throwable err) => print("Failed to open file ``err``")
   );
   ~~~
   
   # AsyncFile
   
   Instances of [[AsyncFile]] are returned from calls to `open` and you use them to read from and write to
   files asynchronously. They allow asynchronous random file access.
   
   [[AsyncFile]] implements [[io.vertx.ceylon.stream::ReadStream]] and [[io.vertx.ceylon.stream::WriteStream]] so you
   can pump files to and from other stream objects such as net sockets, http requests and responses, and WebSockets.
   
   They also allow you to read and write directly to them.
   
   ## Random access writes
   
   To use an [[AsyncFile]] for random access writing you use the [[AsyncFile.write]] method.
   
   `write(buffer, position)`
   
   The parameters to the method are:
   
   - `buffer`: the buffer to write.
   - `position`: an integer position in the file where to write the buffer. If the position is greater or equal to the size of the file, the file will be enlarged to accomodate the offset.
   
   Here is an example of random access writes:
   
   ~~~
   vertx.fileSystem.open("some-file.dat").onComplete {
     void onFulfilled(AsyncFile file) {
       // File open, write a buffer 5 times into a file
       value buff = Buffer("foo");
       for (i in 0..5) {
         value promise = asyncFile.write(buff, buff.length() * i);
         promise.onComplete(
           (Null n) => print("Written ok!"),
           (Throwable err) => print("Failed to write  ``err``")
         );
     },
     void onRejected(Throwable err) {
       print("Failed to write  ``err``");
     }
   };
   ~~~
   
   ## Random access reads
   
   To use an [[AsyncFile]] for random access reads you use the [[AsyncFile.read]] method.
   
   `read(buffer, offset, position, length)`.
   
   The parameters to the method are:
   
   - `buffer`: the buffer into which the data will be read.
   - `offset`: an integer offset into the buffer where the read data will be placed.
   - `position`: the position in the file where to read data from.
   - `length`: the number of bytes of data to read
   
   Here's an example of random access reads:
   
   ~~~
   vertx.fileSystem.open("some-file.dat").onComplete {
     void onFulfilled(AsyncFile file) {
       // File open, write a buffer 5 times into a file
       value buff = Buffer(1000);
       for (i in 0..10) {
         value promise = file.read(buff, i * 100, 100);
         promise.onComplete(
           (Null n) => print("Read ok!"),
           (Throwable err) => print("Failed to read  ``err``")
         );
     },
     void onRejected(Throwable err) {
       print("Failed to read  ``err``");
     }
   };
   ~~~
   
   If you attempt to read past the end of file, the read will not fail but it will simply read zero bytes.
   
   ## Flushing data to underlying storage.
   
   If the [[AsyncFile]] was not opened with `flush = true`, then you can manually flush any writes from
   the OS cache by calling the [[AsyncFile.flush]] method.
   
   This method can also be called with an handler which will be called when the flush is complete.
   
   ## Using AsyncFile as ReadStream and WriteStream
   
   [[AsyncFile]] implements [[io.vertx.ceylon.stream::ReadStream]] and [[io.vertx.ceylon.stream::WriteStream]]. You can then use them
   with a pump to pump data to and from other read and write streams.
   
   Here's an example of pumping data from a file on a client to a HTTP request:
   
   ~~~
   value client = vertx.createHttpClient { host = "foo.com" };
   
   vertx.fileSystem.open("some-file.dat").onComplete {
     void onFulfilled(AsyncFile file) {
       value request = client.put("/uploads");
       request.response.onComplete((HttpClientResponse resp) => print("Received response: ``resp.statusCode``") );
       request.chunked = true;
       value pump = file.readStream.pump(request.stream);
       pump.start();
       file.readStream.endHandler(request.end); // File sent, end HTTP request
     },
     void onRejected(Throwable err) {
       print(""Failed to open file ``err``");
     }
   };   
   ~~~
   
   ## Closing an AsyncFile
   
   To close an [[AsyncFile]] call the [[AsyncFile.close]] method. Closing is asynchronous and if you want
   to be notified when the close has been completed you can use the returned promise.
   """

shared package io.vertx.ceylon.file;
