const fs = require("fs")

const FILE_TEST = "test/interpreter/fs/data/test.txt"
const FILE_TEST_LINK = "test/interpreter/fs/data/test-link.txt"
const FILE_TMP = "test/interpreter/fs/data/tmp.txt"
const DIR_READDIR = "test/interpreter/fs/readdir"
const DIR_TMPDIR = "test/interpreter/fs/data/tmpdirectory"
const DIR_DATA = "test/interpreter/fs/data"

export = ->(describe, it, assert) {

  describe("fs", ->{

    describe("stat", ->{

      describe("regular files", ->{

        it("returns an object containing specific keys", ->{
          const stat = fs.stat(FILE_TEST)

          assert(typeof stat, "Object")
          assert(typeof stat.dev, "Numeric")
          assert(typeof stat.mode, "Numeric")
          assert(typeof stat.nlink, "Numeric")
          assert(typeof stat.uid, "Numeric")
          assert(typeof stat.gid, "Numeric")
          assert(typeof stat.rdev, "Numeric")
          assert(typeof stat.blksize, "Numeric")
          assert(typeof stat.ino, "Numeric")
          assert(typeof stat.size, "Numeric")
          assert(typeof stat.blocks, "Numeric")
          assert(typeof stat.atime, "Numeric")
          assert(typeof stat.mtime, "Numeric")
          assert(typeof stat.ctime, "Numeric")
        })

      })

      describe("symbolic links", ->{

        it("returns an object containing specific keys", ->{
          const stat = fs.lstat(FILE_TEST_LINK)

          assert(typeof stat, "Object")
          assert(typeof stat.dev, "Numeric")
          assert(typeof stat.mode, "Numeric")
          assert(typeof stat.nlink, "Numeric")
          assert(typeof stat.uid, "Numeric")
          assert(typeof stat.gid, "Numeric")
          assert(typeof stat.rdev, "Numeric")
          assert(typeof stat.blksize, "Numeric")
          assert(typeof stat.ino, "Numeric")
          assert(typeof stat.size, "Numeric")
          assert(typeof stat.blocks, "Numeric")
          assert(typeof stat.atime, "Numeric")
          assert(typeof stat.mtime, "Numeric")
          assert(typeof stat.ctime, "Numeric")
        })

      })

    })

    describe("read", ->{

      it("returns the contents of a file", ->{
        const file = fs.read(FILE_TEST, "utf8")

        assert(file, [
          "Hello World",
          "My name is Charly",
          "What is yours?",
          ""
        ].join("\n"))
      })

    })

    describe("open", ->{

      it("returns a File object", ->{
        const file = fs.open(FILE_TEST, "r", "utf8")
        assert(file.__class.name, "File")

        file.close()
      })

    })

    describe("constants", ->{

      it("has some constants defined", ->{
        assert(fs.LINE_SEPARATOR, "\n")
        assert(fs.SEPARATOR, "/")
      })

    })

    describe("instance", ->{

      describe("properties", ->{

        it("has the correct properties", ->{
          const file = fs.open(FILE_TEST, "r", "utf8")

          assert(typeof file.fd, "Numeric")
          assert(typeof file.filename, "String")
          assert(typeof file.mode, "String")
          assert(typeof file.encoding, "String")

          file.close()
        })

        it("puts the absolute path into the filename property", ->{
          const file = fs.open(FILE_TEST, "r", "utf8")

          assert(file.filename.first(), "/")

          file.close()
        })

        it("puts encoding and mode into the File object", ->{
          const file = fs.open(FILE_TEST, "r", "utf8")

          assert(file.mode, "r")
          assert(file.encoding, "utf8")

          file.close()
        })

      })

      describe("methods", ->{

        describe("close", ->{

          it("closes a file", ->{
            const file = fs.open(FILE_TEST, "r", "utf8")
            file.close()

            try {
              file.puts("this should throw")
            } catch(e) {
              assert(true, true)
              return
            }

            assert(false, "Expected an exception")
          })

        })

        describe("print", ->{

          it("prints into a file", ->{
            const file = fs.open(FILE_TMP, "w+", "utf8")

            file.print("hello")
            file.print("hello")
            file.print("hello")
            file.print("hello")

            file.close()

            const content = fs.read(FILE_TMP, "utf8")

            assert(content, "hellohellohellohello")
          })

        })

        describe("puts", ->{

          it("puts into a file", ->{
            const file = fs.open(FILE_TMP, "w+", "utf8")

            file.puts("hello")
            file.puts("hello")
            file.puts("hello")
            file.puts("hello")

            file.close()

            const content = fs.read(FILE_TMP, "utf8")

            assert(content, "hello\nhello\nhello\nhello\n")
          })

        })

        describe("gets", ->{

          it("reads a single line from a file", ->{
            const file = fs.open(FILE_TEST, "r", "utf8")

            assert(file.gets(), "Hello World")
            assert(file.gets(), "My name is Charly")
            assert(file.gets(), "What is yours?")
            assert(file.gets(), null)

            file.close()
          })

        })

        describe("read_char", ->{

          it("reads a single char from a file", ->{
            const file = fs.open(FILE_TEST, "r", "utf8")

            assert(file.read_char(), "H")
            assert(file.read_char(), "e")
            assert(file.read_char(), "l")
            assert(file.read_char(), "l")
            assert(file.read_char(), "o")
            assert(file.read_char(), " ")

            file.close()
          })

        })

        describe("read_bytes", ->{

          it("reads a couple bytes from a file", ->{
            const file = fs.open(FILE_TEST, "r", "utf8")

            assert(file.read_bytes(12), [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 10])

            file.close()
          })

        })

        describe("write_bytes", ->{

          it("writes bytes to a file", ->{
            let file = fs.open(FILE_TMP, "w+", "utf8")

            const data = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

            file.write_bytes(data)

            file.close()

            file = fs.open(FILE_TMP, "r", "utf8")

            assert(file.read_bytes(11), data)

            file.close()
          })

        })

      })

    })

    describe("readdir", ->{

      it("returns the contents of a directory", ->{
        const entries = fs.readdir(DIR_READDIR)
        assert(entries, [".", "..", "bar", "baz", "foo"])
      })

    })

    describe("unlink", ->{

      it("unlinks a file", ->{
        const file = fs.open(DIR_READDIR + "/unlinkme.txt", "w+", "utf8")
        file.close()

        assert(fs.readdir(DIR_READDIR), [".", "..", "bar", "baz", "foo", "unlinkme.txt"])

        fs.unlink(DIR_READDIR + "/unlinkme.txt")

        assert(fs.readdir(DIR_READDIR), [".", "..", "bar", "baz", "foo"])
      })

    })

    describe("mkdir", ->{

      it("creates new directories", ->{
        fs.mkdir(DIR_TMPDIR)

        const stat = fs.stat(DIR_TMPDIR)
        assert(stat.directory, true)

        fs.rmdir(DIR_TMPDIR)
      })

    })

    describe("write", ->{

      it("writes data to a file", ->{
        fs.write(FILE_TMP, "Hello World!")
        const content = fs.read(FILE_TMP, "utf8")
        assert(content, "Hello World!")
      })

    })

    describe("append", ->{

      it("appends data to a file", ->{
        fs.write(FILE_TMP, "Hello ")
        fs.append(FILE_TMP, "World")
        const content = fs.read(FILE_TMP, "utf8")
        assert(content, "Hello World")
      })

    })

    describe("chmod", ->{

      it("changes the mode of a file", ->{
        fs.open(FILE_TMP, "w", "utf8")
        fs.chmod(FILE_TMP, 64)

        let stat = fs.stat(FILE_TMP)

        assert(stat.perm, 64)
        fs.chmod(FILE_TMP, 420)

        stat = fs.stat(FILE_TMP)
        assert(stat.perm, 420)
      })

    })

    describe("chown", ->{

      it("changes the owner of a file", ->{

        // changing the owner and group of a file requires special permissions
        // so we just test if the methods and corresponding internal methods
        // exist

        assert(typeof fs.chown, "Function")
        assert(typeof __internal__method("fs_chown"), "Function")
      })

    })

    describe("link", ->{

      it("creates a new link", ->{
        fs.link(FILE_TEST, DIR_DATA + "/test-direct-link.txt")

        const content = fs.read(DIR_DATA + "/test-direct-link.txt", "utf8")

        assert(content, [
          "Hello World",
          "My name is Charly",
          "What is yours?",
          ""
        ].join("\n"))

        const stat = fs.lstat(DIR_DATA + "/test-direct-link.txt")
        assert(stat.symlink, false)

        fs.unlink(DIR_DATA + "/test-direct-link.txt")
      })

    })

    describe("symlink", ->{

      it("creates a new symbolic link", ->{
        fs.symlink(fs.basename(FILE_TEST), DIR_DATA + "/test-symbolic-link.txt")

        const content = fs.read(DIR_DATA + "/test-symbolic-link.txt", "utf8")

        assert(content, [
          "Hello World",
          "My name is Charly",
          "What is yours?",
          ""
        ].join("\n"))

        const stat = fs.lstat(DIR_DATA + "/test-symbolic-link.txt")
        assert(stat.symlink, true)

        fs.unlink(DIR_DATA + "/test-symbolic-link.txt")
      })

    })

    describe("readlink", ->{

      it("returns an absolute path", ->{
        fs.link(FILE_TEST, DIR_DATA + "/test-direct-link.txt")

        const content = fs.read(DIR_DATA + "/test-direct-link.txt", "utf8")
        assert(content, [
          "Hello World",
          "My name is Charly",
          "What is yours?",
          ""
        ].join("\n"))

        fs.unlink(DIR_DATA + "/test-direct-link.txt")
      })

    })

    describe("rename", ->{

      it("moves a file", ->{
        fs.open(DIR_DATA + "/rename.txt", "w+", "utf8").print("Hello World").close()

        assert(fs.stat(DIR_DATA + "/rename.txt") ! null, true)

        fs.rename(DIR_DATA + "/rename.txt", DIR_DATA + "/rename-new.txt")

        assert(fs.stat(DIR_DATA + "/rename.txt"), null)
        assert(fs.stat(DIR_DATA + "/rename-new.txt") ! null, true)

        fs.rename(DIR_DATA + "/rename-new.txt", DIR_DATA + "/rename.txt")

        assert(fs.stat(DIR_DATA + "/rename.txt") ! null, true)
        assert(fs.stat(DIR_DATA + "/rename-new.txt"), null)

        fs.unlink(DIR_DATA + "/rename.txt")
      })

    })

    describe("delete", ->{

      it("removes files", ->{
        fs.open(DIR_DATA + "/delete.txt", "w", "utf8").close()

        assert(fs.stat(DIR_DATA + "/delete.txt") ! null, true)

        fs.delete(DIR_DATA + "/delete.txt")

        assert(fs.stat(DIR_DATA + "/delete.txt"), null)
      })

      it("removes directories", ->{
        fs.mkdir(DIR_DATA + "/delete")

        assert(fs.stat(DIR_DATA + "/delete") ! null, true)

        fs.delete(DIR_DATA + "/delete")

        assert(fs.stat(DIR_DATA + "/delete"), null)
      })

    })

    describe("empty", ->{

      it("checks if a file is empty", ->{
        fs.open(DIR_DATA + "/emptyfile", "w", "utf8").close()

        assert(fs.empty(DIR_DATA + "/emptyfile"), true)

        fs.unlink(DIR_DATA + "/emptyfile")
      })

      it("returns true if the file doesn't exist", ->{
        assert(fs.empty(DIR_DATA + "/foo"), true)
      })

    })

    describe("convenience methods for stat", ->{

      describe("is_directory", ->{

        it("returns true if the path is a directory", ->{
          assert(fs.is_directory(DIR_DATA), true)
          assert(fs.is_directory(FILE_TEST), false)
          assert(fs.is_directory(FILE_TEST_LINK), false)
        })

      })

      describe("is_file", ->{

        it("returns true if the path is a file", ->{
          assert(fs.is_file(DIR_DATA), false)
          assert(fs.is_file(FILE_TEST), true)
          assert(fs.is_file(FILE_TEST_LINK), false)
        })

      })

      describe("is_link", ->{

        it("returns true if the path is a symlink", ->{
          assert(fs.is_link(DIR_DATA), false)
          assert(fs.is_link(FILE_TEST), false)
          assert(fs.is_link(FILE_TEST_LINK), true)
        })

      })

    })

    describe("exists", ->{

      it("returns true if a file exists", ->{
        assert(fs.exists(DIR_DATA), true)
        assert(fs.exists(FILE_TEST), true)
        assert(fs.exists(FILE_TEST_LINK), true)

        assert(fs.exists(DIR_DATA + "/foo"), false)
        assert(fs.exists(DIR_DATA + "/invalid-link"), false)
      })

    })

  })

}
