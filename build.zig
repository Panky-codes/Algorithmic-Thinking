const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // This build script allows you to build/run individual solution files.
    // It scans the `src` directory (recursively, if we wanted, but let's stick to explicit addition or flat for now, 
    // or better: just let the user add them or use a helper to scan).
    
    // For simplicity in a competitive programming/algorithm context, 
    // we can make a helper that adds a run step for a specific source file.
    
    // Example usage: zig build run -Dproblem=src/chapter1/problem1.zig

    const problem_path = b.option([]const u8, "problem", "Path to the problem file to run (e.g., src/chapter1/p1.zig)");

    if (problem_path) |path| {
        const exe_name = std.fs.path.stem(path);
        
        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(path),
                .target = target,
                .optimize = optimize,
            }),
        });

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the selected problem");
        run_step.dependOn(&run_cmd.step);
    }
}
