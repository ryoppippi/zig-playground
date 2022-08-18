const std = @import("std");
const c = @import("c.zig");

pub fn main() !void {
    var width: c_int = undefined;
    var height: c_int = undefined;
    _ = c.stbi_load("./lena_color.png", &width, &height, null, 0);
    std.debug.print("width:{d}, height:{d}", .{ width, height });
}
