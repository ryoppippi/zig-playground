const std = @import("std");
const fmt = std.fmt;
const ArrayList = std.ArrayList;
const Order = std.math.Order;
const PriorityQueue = std.PriorityQueue;
const Mutex = std.Thread.Mutex;

fn f(context: void, _: u32, _: u32) Order {
    _ = context;
    return Order.eq;
}

const PQeq = PriorityQueue(u32, void, f);

pub const io_mode = .evented;

pub const task_num = 30;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var mutex: Mutex = .{};
    var queue = PQeq.init(allocator, {});
    var is_all_tasks_queued: bool = false;

    // parse command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);
    var cpu: u32 = if (args.len > 1) try fmt.parseUnsigned(u32, args[1], 10) else @intCast(u32, try std.Thread.getCpuCount());
    std.debug.print("Threads:\t{}\n\n", .{cpu});

    // allocate result list
    var results = try allocator.alloc(u32, cpu);
    defer allocator.free(results);
    for (results) |*item| item.* = 0;

    // Allocate room for an async frame for every
    // logical cpu core
    var promises =
        try allocator.alloc(@Frame(worker), cpu);
    defer allocator.free(promises);

    // Start a worker on every cpu
    while (cpu > 0) : (cpu -= 1) {
        promises[cpu - 1] =
            async worker(cpu - 1, &is_all_tasks_queued, &mutex, &queue, &results);
    }

    // add task
    std.debug.print("Add tasks\n", .{});
    {
        var i: u32 = 0;
        while (i < task_num) : (i += 1) {
            if (mutex.tryLock()) {
                try queue.add(i);
                mutex.unlock();
            }
        }
        is_all_tasks_queued = true;
        std.debug.print("Add tasks queued done\n", .{});
    }

    std.debug.print("Working...\n", .{});

    // Wait for a worker to find the solution
    for (promises) |*future| {
        _ = await future;
    }

    var sum: u32 = 0;
    std.debug.print("Sum\n", .{});
    for (results) |item, i| {
        sum += item;
        std.debug.print("cpu:{}\tsum:{}\n", .{ i, item });
    }
    try std.testing.expectEqual(sum, task_num * (task_num - 1) / 2);
}

fn worker(cpu_uid: u32, is_all_tasks_queued: *bool, mutex: *Mutex, queue: *PQeq, results: *[]u32) !void {
    std.event.Loop.startCpuBoundOperation();

    var task: ?u32 = undefined;
    while (true) {
        if (mutex.*.tryLock()) {
            task = queue.*.removeOrNull();
            mutex.*.unlock();
            if (task == null) {
                // if (@atomicLoad(bool, is_all_tasks_queued, std.builtin.AtomicOrder.Acquire)) {
                if (is_all_tasks_queued.*) {
                    return;
                }
            } else {
                results.*[cpu_uid] += task.?;
                std.debug.print("cpu: {}\ttask: {}\n", .{ cpu_uid, task });
            }
        }
        std.time.sleep(200 * std.time.ns_per_ms);
    }
}
