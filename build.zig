const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = .ReleaseFast;
    const src_dir = "src/";

    const exe = b.addExecutable(.{
        .name = "ZIO-S",
        .root_source_file = b.path(src_dir ++ "main.zig"),
        .optimize = optimize,
        .target = target,
    });

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run ZIO-S");
    run_step.dependOn(&run_cmd.step);

    b.installArtifact(exe);
}
