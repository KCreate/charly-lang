const fs = require("fs")

const FILE_TEST = "test/interpreter/fs/data/test.txt"
const FILE_TEST_LINK = "test/interpreter/fs/data/test-link.txt"
const FILE_TMP = "test/interpreter/fs/data/tmp.txt"
const DIR_READDIR = "test/interpreter/fs/readdir"
const DIR_TMPDIR = "test/interpreter/fs/data/tmpdirectory"

export = ->(describe, it, assert) {

  describe("File", ->{

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

    describe("type", ->{

      it("returns the type of files", ->{
        const typ_unknown = fs.type("foo")
        const typ_file = fs.type(FILE_TEST)
        const typ_dir = fs.type(DIR_READDIR)
        const typ_link = fs.type(FILE_TEST_LINK)

        assert(typ_unknown, fs.TYPES.UNKNOWN)
        assert(typ_file, fs.TYPES.FILE)
        assert(typ_dir, fs.TYPES.DIR)
        assert(typ_link, fs.TYPES.LINK)
      })

      it("has constants defined in fs.TYPES", ->{
        assert(fs.TYPES.FILE, 0)
        assert(fs.TYPES.DIR, 1)
        assert(fs.TYPES.LINK, 2)
      })

    })

    describe("mkdir", ->{

      it("creates new directories", ->{
        let typ = fs.type(DIR_TMPDIR)

        assert(typ, fs.TYPES.UNKNOWN)

        fs.mkdir(DIR_TMPDIR)

        typ = fs.type(DIR_TMPDIR)

        assert(typ, fs.TYPES.DIR)

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

  })

}
