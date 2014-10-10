import ceylon.test {
  beforeTest,
  assertEquals,
  test
}
import ceylon.file {
  current,
  ExistingResource,
  Directory,
  Nil,
  File
}
import io.vertx.ceylon.core {
  Vertx
}
import ceylon.language.meta {
  type
}
import io.vertx.ceylon.core.file {
  FileProps,
  AsyncFile
}
import ceylon.time {
  now
}
import org.vertx.java.core.buffer {
  Buffer
}
import ceylon.promise {
  Deferred
}
shared class FileSystemTest() {
  
  value workRes = current.childPath("work").resource;
  Directory workDir;
  switch (workRes)
  case (is Directory) {
    workDir = workRes;
  }
  case (is Nil) {
    workDir = workRes.createDirectory();
  }
  else {
    throw Exception("Was not expecting work dir to be ``type(workRes)``");
  }
  
  void createFile(String name, String? content = null) {
    value path = workDir.path.childPath(name);
    assert (is Nil res = path.resource);
    File f = res.createFile();
    if (exists content) {
      value writer = f.writer();
      try {
        writer.write(content);
      } finally {
        writer.close();
      }
    }
  }
  
  void assertDir(String name) {
    value res = workDir.path.childPath(name).resource;
    assert (is Directory res);
  }
  
  Buffer assertFile(String name) {
    value res = workDir.path.childPath(name).resource;
    assert (is File res);
    value bytes = res.reader().readBytes(res.size);
    value buffer = Buffer(bytes.size);
    variable Integer index = 0;
    for (b in bytes) {
      buffer.setByte(index++, b);
    }
    return buffer;
  }
  
  void assertNil(String name) {
    value res = workDir.path.childPath(name).resource;
    assert (is Nil res);
  }
  
  shared beforeTest
  void cleanupDir() {
    for (childPath in workDir.childPaths()) {
      value childRes = childPath.resource;
      assert (is ExistingResource childRes);
      childRes.delete();
    }
  }
  
  shared test
  void testExists() {
    createFile("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      assertEquals(true, fs.\iexists("work/foo.txt").future.get());
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testCopy() {
    createFile("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      fs.copy("work/foo.txt", "work/bar.txt").future.get();
      assertFile("foo.txt");
      assertFile("bar.txt");
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testMove() {
    createFile("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      fs.move("work/foo.txt", "work/bar.txt").future.get();
      assertNil("foo.txt");
      assertFile("bar.txt");
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testDelete() {
    createFile("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      fs.delete("work/foo.txt").future.get();
      assertNil("foo.txt");
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testCreate() {
    assertNil("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      fs.createFile("work/foo.txt").future.get();
      assertFile("foo.txt");
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testMkdir() {
    assertNil("foo");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      fs.mkdir("work/foo").future.get();
      assertDir("foo");
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testReadDir() {
    createFile("foo.txt");
    createFile("bar.txt");
    createFile("juu.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      value names = fs.readDir("work").future.get();
      assert (is {String*} names);
      assertEquals(["bar.txt", "foo.txt", "juu.txt"], sort(names.map((String element) => element.spanFrom(element.size - 7))));
      value t = fs.readDir("work/foo.txt").future.get();
      assert (is Throwable t);
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testProps() {
    createFile("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      value props = fs.props("work/foo.txt").future.get();
      assert (is FileProps props);
      value dateTime = now().dateTime();
      for (i in { props.creationTime, props.lastAccessTime, props.lastModifiedTime }) {
        assert (i.rangeTo(dateTime).duration.milliseconds < 2000); // < 2 seconds
      }
      assertEquals(true, props.regularFile);
      assertEquals(false, props.directory);
      assertEquals(false, props.symbolicLink);
      assertEquals(0, props.size);
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testReadFile() {
    createFile("foo.txt", "helloworld");
    value buffer = assertFile("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      assertEquals(buffer, fs.readFile("work/foo.txt").future.get());
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testWriteFile() {
    assertNil("foo.txt");
    value vertx = Vertx();
    try {
      value fs = vertx.fileSystem;
      value content = Buffer("helloworld");
      fs.writeFile("work/foo.txt", content).future.get();
      value buffer = assertFile("foo.txt");
      assertEquals(content, buffer);
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testAsyncFileRead() {
    value expected = Buffer("helloworld");
    createFile("foo.txt", "helloworld");
    value vertx = Vertx();
    try {
      Deferred<Buffer> d = Deferred<Buffer>();
      vertx.runOnContext(void() {
          value fs = vertx.fileSystem;
          value buffer = fs.open("work/foo.txt").compose<Buffer>((AsyncFile file) => file.read(Buffer(10), 0, 0, 10));
          d.fulfill(buffer);
        });
      value buffer = d.promise.future.get();
      assertEquals(buffer, expected);
    } finally {
      vertx.stop();
    }
  }
  
  shared test
  void testAsyncFileWrite() {
    value expected = Buffer("helloworld");
    value vertx = Vertx();
    try {
      Deferred<Anything> d = Deferred<Anything>();
      vertx.runOnContext(void() {
          value fs = vertx.fileSystem;
          fs.open("work/foo.txt").onComplete(void(AsyncFile file) {
              file.write(expected, 0);
              d.fulfill("");
            });
        });
      d.promise.future.get();
    } finally {
      vertx.stop();
    }
    value buffer = assertFile("foo.txt");
    assertEquals(expected, buffer);
  }
  
  shared test
  void testPump() {
    value expected = Buffer("helloworld");
    createFile("foo.txt", "helloworld");
    value vertx = Vertx();
    try {
      Deferred<Null> d = Deferred<Null>();
      vertx.runOnContext(void() {
          value fs = vertx.fileSystem;
          value src = fs.openSync("work/foo.txt");
          value dst = fs.openSync("work/bar.txt");
          value pump = src.readStream.pump(dst.writeStream);
          pump.start();
          src.readStream.endHandler(void() {
              dst.close();
              d.fulfill(null);
            });
        });
      value done = d.promise.future.get();
      assertEquals(done, null);
    } finally {
      vertx.stop();
    }
    assertEquals(assertFile("bar.txt"), expected);
  }
}
