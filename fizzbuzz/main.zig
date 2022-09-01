const std = @import("std");
const allocPrint = std.fmt.allocPrint;

fn fizzbuzz(i: u32, allocator: anytype) ![]const u8 {
    const div_3: u2 = @boolToInt(@mod(i, 3) == 0);
    const div_5 = @boolToInt(@mod(i, 5) == 0);

    return switch (div_3 << 1 | div_5) {
        0b10 => try allocPrint(allocator, "Fizz", .{}),
        0b11 => try allocPrint(allocator, "FizzBuzz", .{}),
        0b01 => try allocPrint(allocator, "Buzz", .{}),
        0b00 => try allocPrint(allocator, "{d}", .{i}),
    };
}

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
