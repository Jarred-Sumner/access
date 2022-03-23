const std = @import("std");

pub fn main() anyerror!void {
    var args = std.process.args();
    _ = args.next();
    const path = std.heap.c_allocator.dupeZ(u8, args.next() orelse {
        std.debug.print("Usage: filepath [RWXF]\n\n  R: R_OK – is it readable?\n  W: W_OK – is it writable?\n  X: X_OK – is it executable?\n  F: Does it exist? (default)\n\n  See access(2) – https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/access.2.html\n", .{});
        std.os.exit(0);
    }) catch unreachable;

    var mode: c_uint = 0;
    if (args.next()) |arg| {
        for (std.mem.span(arg)) |c| {
            mode |= switch (c) {
                'R', 'r' => @as(c_uint, std.os.R_OK),
                'F', 'f' => @as(c_uint, std.os.F_OK),
                'X', 'x' => @as(c_uint, std.os.X_OK),
                'W', 'w' => @as(c_uint, std.os.W_OK),
                else => @as(c_uint, 0),
            };
        }
    } else {
        mode = std.os.F_OK;
    }

    const result = std.c.access(path, mode);
    switch (result) {
        else => {
            var stderr = std.io.getStdErr();
            var writer = stderr.writer();
            try writer.print("Error: E{s}\n", .{std.mem.span(@tagName(std.c.getErrno(result)))});
            std.os.exit(1);
        },
        0 => {
            var stderr = std.io.getStdOut();
            var writer = stderr.writer();

            if (mode == std.os.F_OK or ((mode & std.os.F_OK) != 0)) {
                try writer.print("\"{s}\" exists\n", .{std.mem.span(path)});
                std.os.exit(0);
            }

            try writer.print("\"{s}\" is:", .{std.mem.span(path)});

            if ((mode & std.os.R_OK) != 0) {
                try writer.writeAll("\n   readable (R_OK)");
            }

            if ((mode & std.os.W_OK) != 0) {
                try writer.writeAll("\n   writable (W_OK)");
            }

            if ((mode & std.os.X_OK) != 0) {
                try writer.writeAll("\n   executable (X_OK)");
            }

            try writer.writeAll("\n");

            std.os.exit(0);
        },
    }
}
