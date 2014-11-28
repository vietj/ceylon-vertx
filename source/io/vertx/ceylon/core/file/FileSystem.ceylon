import org.vertx.java.core.file {
  FileSystem_=FileSystem,
  FileProps_=FileProps,
  AsyncFile_=AsyncFile,
  FileSystemProps_=FileSystemProps
}
import java.util {
  Date_=Date,
  GregorianCalendar_=GregorianCalendar
}
import ceylon.promise {
  Promise,
  ExecutionContext
}
import io.vertx.ceylon.core.util {
  AsyncResultPromise,
  voidAsyncResult,
  booleanAsyncResult,
  stringAsyncResult,
  stringArrayAsyncResult,
  asyncResult,
  fromStringArray
}
import ceylon.time {
  DateTime,
  dateTime
}
import org.vertx.java.core.buffer {
  Buffer
}
import io.vertx.ceylon.core {
  Vertx
}

""" Contains a broad set of operations for manipulating files.
   
   An asynchronous and a synchronous version of each operation is provided.
   
   The asynchronous versions take a handler which is called when the operation completes or an error occurs.
   
   The synchronous versions return the results, or throw exceptions directly.
   
   It is highly recommended the asynchronous versions are used unless you are sure the operation
   will not block for a significant period of time.
  
   Instances of FileSystem are thread-safe."""
shared class FileSystem(Vertx vertx, FileSystem_ delegate) {
  
  ExecutionContext context = vertx.executionContext;
  
  """Copy a file from the path [[from]] to path [[to]], asynchronously.
     
     If [[recursive]] is `true` and [[from]] represents a directory, then the directory and its contents
     will be copied recursively to the destination [[to]].
     
     The copy will fail if the destination if the destination already exists."""
  shared Promise<Anything> copy(String from, String to, Boolean? recursive = null) {
    value result = voidAsyncResult(context);
    if (exists recursive) {
      delegate.copy(from, to, recursive, result);
    } else {
      delegate.copy(from, to, result);
    }
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.copy]]"
  shared FileSystem copySync(String from, String to, Boolean? recursive = null) {
    if (exists recursive) {
      delegate.copySync(from, to, recursive);
    } else {
      delegate.copySync(from, to);
    }
    return this;
  }
  
  """Move a file from the path [[from]] to path [[to]], asynchronously.
     
     The move will fail if the destination already exists."""
  shared Promise<Anything> move(String from, String to) {
    value result = voidAsyncResult(context);
    delegate.move(from, to, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.move]]"
  shared FileSystem moveSync(String from, String to) {
    delegate.moveSync(from, to);
    return this;
  }
  
  """Truncate the file represented by [[path]] to length [[len]] in bytes, asynchronously.
     
     The operation will fail if the file does not exist or [[len]] is less than `0`."""
  shared Promise<Anything> truncate(String path, Integer len) {
    value result = voidAsyncResult(context);
    delegate.truncate(path, len, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.truncate]]"
  shared FileSystem truncateSync(String path, Integer len) {
    delegate.truncateSync(path, len);
    return this;
  }
  
  """Change the permissions on the file represented by [[path]] to [[perms]], asynchronously.
     
     The permission String takes the form `rwxr-x---` as specified in
     [here](http://download.oracle.com/javase/7/docs/api/java/nio/file/attribute/PosixFilePermissions.html).
     
     If the file is directory then all contents will also have their permissions changed recursively. Any directory
     permissions will be set to [[dirPerms]], whilst any normal file permissions will be set to [[perms]]."""
  shared Promise<Anything> chmod(String path, String perms, String? dirPerms = null) {
    value result = voidAsyncResult(context);
    if (exists dirPerms) {
      delegate.chmod(path, perms, dirPerms, result);
    } else {
      delegate.chmod(path, perms, result);
    }
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.chmod]]"
  shared FileSystem chmodSync(String path, String perms, String? dirPerms = null) {
    if (exists dirPerms) {
      delegate.chmodSync(path, perms, dirPerms);
    } else {
      delegate.chmodSync(path, perms);
    }
    return this;
  }
  
  "Change the ownership on the file represented by [[path]] to [[user]] and [[group]], asynchronously."
  shared Promise<Anything> chown(String path, String user, String group) {
    value result = voidAsyncResult(context);
    delegate.chown(path, user, group, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.chown]]"
  shared FileSystem chownSync(String path, String user, String group) {
    delegate.chownSync(path, user, group);
    return this;
  }
  
  DateTime toDateTime(Date_ date) {
    value cal = GregorianCalendar_();
    cal.time = date;
    return dateTime(
      cal.get(GregorianCalendar_.\iYEAR),
      1 + cal.get(GregorianCalendar_.\iMONTH),
      cal.get(GregorianCalendar_.\iDAY_OF_MONTH),
      cal.get(GregorianCalendar_.\iHOUR_OF_DAY),
      cal.get(GregorianCalendar_.\iMINUTE),
      cal.get(GregorianCalendar_.\iSECOND),
      cal.get(GregorianCalendar_.\iMILLISECOND)
    );
  }
  
  FileProps fileProps(FileProps_ fp) =>
      FileProps(
    toDateTime(fp.creationTime()),
    toDateTime(fp.lastAccessTime()),
    toDateTime(fp.lastModifiedTime()),
    fp.directory,
    fp.other,
    fp.regularFile,
    fp.symbolicLink,
    fp.size()
  );
  
  AsyncResultPromise<FileProps,FileProps_> filePropsAsyncResult() => AsyncResultPromise<FileProps,FileProps_>(context, fileProps);
  
  "Obtain properties for the file represented by [[path]], asynchronously. If the file is a link, the link will be followed."
  shared Promise<FileProps> props(String path) {
    value result = filePropsAsyncResult();
    delegate.props(path, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.props]]"
  shared FileProps propsSync(String path) {
    return fileProps(delegate.propsSync(path));
  }
  
  "Obtain properties for the link represented by [[path]], asynchronously. The link will not be followed."
  shared Promise<FileProps> lprops(String path) {
    value result = filePropsAsyncResult();
    delegate.lprops(path, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.lprops]]"
  shared FileProps lpropsSync(String path) {
    return fileProps(delegate.lpropsSync(path));
  }
  
  "Create a hard link on the file system from [[link]] to [[existing]], asynchronously."
  shared Promise<Anything> link(String link, String existing) {
    value result = voidAsyncResult(context);
    delegate.link(link, existing, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.link]]"
  shared FileSystem linkSync(String link, String existing) {
    delegate.linkSync(link, existing);
    return this;
  }
  
  "Create a symbolic link on the file system from [[link]] to [[existing]], asynchronously."
  shared Promise<Anything> symlink(String link, String existing) {
    value result = voidAsyncResult(context);
    delegate.symlink(link, existing, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.symlink]]"
  shared FileSystem symlinkSync(String link, String existing) {
    delegate.symlinkSync(link, existing);
    return this;
  }
  
  "Unlinks the link on the file system represented by the path [[link]], asynchronously."
  shared Promise<Anything> unlink(String link) {
    value result = voidAsyncResult(context);
    delegate.unlink(link, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.unlink]]"
  shared FileSystem unlinkSync(String link) {
    delegate.unlinkSync(link);
    return this;
  }
  
  "Returns the path representing the file that the symbolic link specified by [[link]] points to, asynchronously."
  shared Promise<String> readSymlink(String link) {
    value result = stringAsyncResult(context);
    delegate.readSymlink(link, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.readSymlink]]"
  shared String readSymlinkSync(String link) {
    return delegate.readSymlinkSync(link);
  }
  
  "Deletes the file represented by the specified [[path]], asynchronously.
   
   If the path represents a directory and [[recursive]] then the directory and its contents will be
   deleted recursively."
  shared Promise<Anything> delete(String path, Boolean? recursive = null) {
    value result = voidAsyncResult(context);
    if (exists recursive) {
      delegate.delete(path, recursive, result);
    } else {
      delegate.delete(path, result);
    }
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.delete]]"
  shared FileSystem deleteSync(String path, Boolean? recursive = null) {
    if (exists recursive) {
      delegate.deleteSync(path, recursive);
    } else {
      delegate.deleteSync(path);
    }
    return this;
  }
  
  """Create the directory represented by [[path]], asynchronously.
     
     The new directory will be created with permissions as specified by [[perms]].
     The permission String takes the form `rwxr-x---` as specified
     in [here](http://download.oracle.com/javase/7/docs/api/java/nio/file/attribute/PosixFilePermissions.html).
     
     If [[createParents]] is set to `true` then any non-existent parent directories of the directory
     will also be created.
     
     The operation will fail if the directory already exists.
     """
  shared Promise<Anything> mkdir(String path, String? perms = null, Boolean? createParents = null) {
    value result = voidAsyncResult(context);
    if (exists createParents) {
      if (exists perms) {
        delegate.mkdir(path, perms, createParents, result);
      } else {
        delegate.mkdir(path, createParents, result);
      }
    } else {
      if (exists perms) {
        delegate.mkdir(path, perms, result);
      } else {
        delegate.mkdir(path, result);
      }
    }
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.mkdir]]"
  shared FileSystem mkdirSync(String path, String? perms = null, Boolean? createParents = null) {
    if (exists createParents) {
      if (exists perms) {
        delegate.mkdirSync(path, perms, createParents);
      } else {
        delegate.mkdirSync(path, createParents);
      }
    } else {
      if (exists perms) {
        delegate.mkdirSync(path, perms);
      } else {
        delegate.mkdirSync(path);
      }
    }
    return this;
  }
  
  """Read the contents of the directory specified by [[path]], asynchronously.
     
     The parameter [[filter]] is a regular expression. If [[filter]] is specified then only the paths that
     match [[filter]] will be returned.
     
     The result is an array of String representing the paths of the files inside the directory."""
  shared Promise<{String*}> readDir(String path, String? filter = null) {
    value result = stringArrayAsyncResult(context);
    if (exists filter) {
      delegate.readDir(path, filter, result);
    } else {
      delegate.readDir(path, result);
    }
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.readDir]]"
  shared {String*} readDirSync(String path, String? filter = null) {
    if (exists filter) {
      return fromStringArray(delegate.readDirSync(path, filter));
    } else {
      return fromStringArray(delegate.readDirSync(path));
    }
  }
  
  """Reads the entire file as represented by the path [[path]] as a `Buffer`, asynchronously.
     
     Do not user this method to read very large files or you risk running out of available RAM."""
  shared Promise<Buffer> readFile(String path) {
    AsyncResultPromise<Buffer,Buffer> result = asyncResult<Buffer>(context);
    delegate.readFile(path, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.readFile]]"
  shared Buffer readFileSync(String path) {
    return delegate.readFileSync(path);
  }
  
  "Creates the file, and writes the specified [[data]] to the file represented by the path [[path]], asynchronously."
  shared Promise<Anything> writeFile(String path, Buffer data) {
    value result = voidAsyncResult(context);
    delegate.writeFile(path, data, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.writeFile]]"
  shared FileSystem writeFileSync(String path, Buffer data) {
    delegate.writeFileSync(path, data);
    return this;
  }
  
  Boolean boolean(Boolean? b, Boolean def) {
    if (exists b) {
      return b;
    } else {
      return def;
    }
  }
  
  """Open the file represented by [[path]], asynchronously.
     
     If [[read]] is `true` the file will be opened for reading. If [[write]] is `true` the file
     will be opened for writing.
     
     If the file does not already exist and [[createNew]] is `true` it will be created with the permissions
     as specified by [[perms]], otherwise the operation will fail.
     
     If [[flush]]} is `true` then all writes will be automatically flushed through OS buffers to the underlying
     storage on each write."""
  shared Promise<AsyncFile> open(String path, String? perms = null, Boolean? read = null, Boolean? createNew = null,
    Boolean? write = null, Boolean? flush = null) {
    AsyncResultPromise<AsyncFile,AsyncFile_> result = AsyncResultPromise<AsyncFile,AsyncFile_>(context, (AsyncFile_ delegate) => AsyncFile(context, path, delegate));
    delegate.open(
      path,
      perms,
      boolean(read, true),
      boolean(write, true),
      boolean(createNew, true),
      boolean(flush, false),
      result
    );
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.open]]"
  shared AsyncFile openSync(String path, String? perms = null, Boolean? read = null,
    Boolean? createNew = null, Boolean? write = null, Boolean? flush = null) {
    return AsyncFile(context, path, delegate.openSync(
        path,
        perms,
        boolean(read, true),
        boolean(write, true),
        boolean(createNew, true),
        boolean(flush, false)));
  }
  
  "Creates an empty file with the specified [[path]] and permissions [[perms]], asynchronously."
  shared Promise<Anything> createFile(String path, String? perms = null) {
    value result = voidAsyncResult(context);
    if (exists perms) {
      delegate.createFile(path, perms, result);
    } else {
      delegate.createFile(path, result);
    }
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.createFile]]"
  shared FileSystem createFileSync(String path) {
    delegate.createFileSync(path);
    return this;
  }
  
  "Determines whether the file as specified by the path [[path]] exists, asynchronously."
  shared Promise<Boolean> \iexists(String path) {
    value result = booleanAsyncResult(context);
    delegate.\iexists(path, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.exists]]"
  shared Boolean existsSync(String path) {
    return delegate.existsSync(path);
  }
  
  "Returns properties of the file-system being used by the specified [[path]], asynchronously."
  shared Promise<FileSystemProps> fsProps(String path) {
    value result = AsyncResultPromise<FileSystemProps,FileSystemProps_>(context,
      (FileSystemProps_ v) => FileSystemProps(v.totalSpace(), v.unallocatedSpace(), v.usableSpace()));
    delegate.fsProps(path, result);
    return result.promise;
  }
  
  "Synchronous version of [[FileSystem.fsProps]]"
  shared FileSystemProps fsPropsSync(String path) {
    value v = delegate.fsPropsSync(path);
    return FileSystemProps(v.totalSpace(), v.unallocatedSpace(), v.usableSpace());
  }
}
