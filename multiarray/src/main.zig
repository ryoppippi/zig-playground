const std = @import("std");
const fmt = std.fmt;
const test_allocator = std.testing.allocator;
const print = std.debug.print;

test "multidimensional array" {
    var arena = std.heap.ArenaAllocator.init(test_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var cpu: usize = @intCast(usize, try std.Thread.getCpuCount());

    var results = try allocator.alloc([]usize, cpu);
    defer allocator.free(results);
    for (results) |*item| item.* = try allocator.alloc(usize, cpu);

    for (results) |_, i| {
        for (results[i]) |*c, j| {
            const l: usize = i * j;
            c.* = l;
        }
    }

    for (results) |_, i| {
        for (results[i]) |_, j| {
            print("{}\t", .{results[i][j]});
        } else {
            print("\n", .{});
        }
    }
    print("{s}\n", .{@typeName(@TypeOf(results))});
}
