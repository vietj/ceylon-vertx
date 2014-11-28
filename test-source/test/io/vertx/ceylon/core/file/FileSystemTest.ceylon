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
import test.io.vertx.ceylon.core {
  assertResolveTo,
  assertResolve
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
      assertResolveTo(fs.\iexists("work/foo.txt"), true);
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
      assertResolve(fs.copy("work/foo.txt", "work/bar.txt"));
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
      assertResolve(fs.move("work/foo.txt", "work/bar.txt"));
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
      assertResolve(fs.delete("work/foo.txt"));
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
      assertResolve(fs.createFile("work/foo.txt"));
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
      assertResolve(fs.mkdir("work/foo"));
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
      value names = assertResolve(fs.readDir("work"));
      assertEquals(["bar.txt", "foo.txt", "juu.txt"], sort(names.map((String element) => element.spanFrom(element.size - 7))));
      value t = assertResolve(fs.readDir("work/foo.txt"));
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
      value props = assertResolve(fs.props("work/foo.txt"));
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
      assertResolveTo(fs.readFile("work/foo.txt"), buffer);
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
      assertResolve(fs.writeFile("work/foo.txt", content));
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
          value buffer = fs.open("work/foo.txt").flatMap((AsyncFile file) => file.read(Buffer(10), 0, 0, 10));
          d.fulfill(buffer);
        });
      value buffer = assertResolve(d.promise);
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
      assertResolve(d.promise);
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
      value done = assertResolve(d.promise);
      assertEquals(done, null);
    } finally {
      vertx.stop();
    }
    assertEquals(assertFile("bar.txt"), expected);
  }
}
