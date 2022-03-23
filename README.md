# test access(2) syscall

Small utility for testing the access(2) syscall.

[Linux](https://man7.org/linux/man-pages/man2/access.2.html) [macOS](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/access.2.html)

```
❯ zig build
❯ ./zig-out/bin/access
Usage: filepath [RWXF]

  R: R_OK – is it readable?
  W: W_OK – is it writable?
  X: X_OK – is it executable?
  F: Does it exist? (default)

  See access(2) – https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/access.2.html

```

```bash
❯ ./zig-out/bin/access apokdsapodk
Error: ENOENT
```

```bash
❯ ./zig-out/bin/access src/main.zig
"src/main.zig" exists
```

```bash
❯ ./zig-out/bin/access src
"src" exists
```
