const std = @import("std");
const c = @import("c.zig").c;

pub fn main() anyerror!void {
    var x: c_int = 0;
    var y: c_int = 0;
    var n: c_int = 0;
    const res = c.stbi_load("./image001.png", &x, &y, &n, c.STBI_grey);
    defer c.stbi_image_free(res);
    std.debug.print("{}", .{res.*});
}
