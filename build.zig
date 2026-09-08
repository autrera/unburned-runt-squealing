const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Allow overriding raylib platform via `-Dplatform` and `-Dopengl_version`.
    // Default to the headless `memory` backend with software rendering so that
    // `zig build` succeeds even in minimal containers without X11 dev headers.
    // For a windowed desktop build, run:
    //   zig build -Dplatform=glfw -Dopengl_version=gl_3_3
    // which requires X11 dev headers (libx11-dev, libxcursor-dev, libxrandr-dev,
    // libxinerama-dev, libxi-dev, libgl1-mesa-dev, libasound2-dev).
    const platform = b.option(rlz.PlatformBackend, "platform", "raylib platform backend") orelse .memory;
    const opengl_version = b.option(rlz.OpenglVersion, "opengl_version", "OpenGL version") orelse .gl_soft;

    // Use dynamic linkage to work around a Zig 0.16 static-archive bug where
    // `zig build-lib -static` bundles system libraries (including nested .a
    // archives) into the outer archive, causing `zig build-exe` to fail with
    // "not an ELF file" when parsing the archive.
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
        .platform = platform,
        .opengl_version = opengl_version,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    exe_mod.addImport("raylib", raylib);
    exe_mod.addImport("raygui", raygui);

    const exe = b.addExecutable(.{
        .name = "raylib_quickstart",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
