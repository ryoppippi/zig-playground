const std = @import("std");
const ex = @import("example.zig");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "clear" {
    try std.io.getStdOut().writer().print("{s}\n", .{"\x1b[2J\x1b[1;1H"});
}

test "static local variable" {
    try expectEqual(@as(i32, 4), ex.get());
    try expectEqual(@as(i32, 5), ex.get());
}
