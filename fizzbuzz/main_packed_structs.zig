const std = @import("std");
const allocPrint = std.fmt.allocPrint;

fn fizzbuzz(i: u32, allocator: anytype) ![]const u8 {
    const f = Flag{ .three = @mod(i, 3) == 0, .five = @mod(i, 5) == 0 };
    return if (f.three) try allocPrint(allocator, "Fizz", .{}) else if (f.three and f.five) try allocPrint(allocator, "FizzBuzz", .{}) else if (f.five) try allocPrint(allocator, "Buzz", .{}) else try allocPrint(allocator, "{d}", .{i});
}

const Flag = packed struct {
    three: bool = false,
    five: bool = false,
};

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();

    var i: u32 = 1;
    while (i <= 100) : (i += 1) {
        const s = try fizzbuzz(i, allocator);
        defer allocator.free(s);
        try stdout.print("{s}\n", .{s});
    }
}
