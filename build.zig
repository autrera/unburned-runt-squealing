const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Allow overriding raylib platform via `-Dplatform` and `-Dopengl_version`.
    // Default to windowed desktop (GLFW + OpenGL 3.3) so `make` / `zig build`
    // opens a native X11/Wayland window in WSL2 via the GLFW desktop backend.
    // For headless software rendering, run:
    //   zig build -Dplatform=memory -Dopengl_version=gl_soft
    // The desktop build requires X11 dev headers and libs (libx11-dev,
    // libxcursor-dev, libxrandr-dev, libxinerama-dev, libxi-dev,
    // libgl1-mesa-dev, libasound2-dev) — see user-space paths below.
    const platform = b.option(rlz.PlatformBackend, "platform", "raylib platform backend") orelse .glfw;
    const opengl_version = b.option(rlz.OpenglVersion, "opengl_version", "OpenGL version") orelse .gl_3_3;

    // Use static linkage so raylib is statically compiled into the executable
    // with no missing `libraylib.so` runtime dependency.
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linkage = .static,
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

    // Automatically configure include and library paths for user-space / WSL2
    // development libraries. Headers and .so symlinks (libGL, libX11,
    // libXcursor, libXi, libXinerama, libXrandr, X11 headers, ALSA headers)
    // are expected under `~/.local/include` and `~/.local/lib`, with
    // fallbacks under `/tmp/fake_sysroot/usr/include` and `/tmp/fake_libs`.
    const raylib_art = raylib_dep.artifact("raylib");
    if (b.graph.environ_map.get("HOME")) |home| {
        const user_inc = b.pathJoin(&.{ home, ".local", "include" });
        const user_lib = b.pathJoin(&.{ home, ".local", "lib" });
        raylib_art.root_module.addIncludePath(.{ .cwd_relative = user_inc });
        raylib_art.root_module.addLibraryPath(.{ .cwd_relative = user_lib });
        exe_mod.addLibraryPath(.{ .cwd_relative = user_lib });
    }
    {
        const fake_inc = "/tmp/fake_sysroot/usr/include";
        var fake_dir = std.Io.Dir.openDirAbsolute(b.graph.io, fake_inc, .{}) catch null;
        if (fake_dir) |*d| {
            d.close(b.graph.io);
            raylib_art.root_module.addIncludePath(.{ .cwd_relative = fake_inc });
        }
    }
    {
        const fake_lib = "/tmp/fake_libs";
        var fake_dir = std.Io.Dir.openDirAbsolute(b.graph.io, fake_lib, .{}) catch null;
        if (fake_dir) |*d| {
            d.close(b.graph.io);
            raylib_art.root_module.addLibraryPath(.{ .cwd_relative = fake_lib });
            exe_mod.addLibraryPath(.{ .cwd_relative = fake_lib });
        }
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
