const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("image0", "src/main.zig");
    exe.setBuildMode(mode);
    // exe.addCSourceFile("vender/stb/stb_image.h", &[_][]const u8{"-std=c99"});
    // exe.addCSourceFile("stb_image-2.22/stb_image_impl.c", &[_][]const u8{"-std=c99"});
    exe.addIncludeDir("stb_image-2.22");
    exe.linkSystemLibrary("c");
    // exe.addIncludePath("vender");
    // exe.linkLibC();
    exe.setTarget(target);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
