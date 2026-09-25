# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## Project state

# unburned-runt-squealing

Zig quickstart template for raylib + raygui (via raylib-zig, pinned raylib 6.0.0 in `build.zig.zon`).

## Build / run

- Requires Zig 0.16.0+ (`minimum_zig_version` in `build.zig.zon`).
- `make` / `make build`: debug-ish build via `zig build` (Makefile default; the build script's own optimize default is `ReleaseFast`).
- `make release`: `-Doptimize=ReleaseFast`. `make run`: build then run.
- Binary: `zig-out/bin/raylib_quickstart`. `make clean` removes `zig-out`, `zig-cache`, `.zig-cache`.

## Layout

- `src/main.zig`: entry point; includes a `searchAndSetResourceDir` helper so `resources/` assets load regardless of the binary's working directory.
- `resources/`: assets.
- `build.zig`, `build.zig.zon`: build script and package manifest (single dependency: `raylib_zig`).
- `Makefile`: wrapper around `zig build`.

## Toolchain / platform notes (from build.zig)

- Options: `-Dplatform=glfw` (default, windowed desktop) or `-Dplatform=memory` (headless software rendering); `-Dopengl_version` defaults to `gl_3_3`.
- Raylib is linked statically; no runtime `libraylib.so` dependency.
- Linux desktop (glfw) needs X11 dev headers/libs (libx11, libxcursor, libxrandr, libxinerama, libxi, libgl1-mesa, libasound2).
- build.zig adds include/lib search paths from `~/.local/{include,lib}`, `/tmp/fake_sysroot/usr/include`, and `/tmp/fake_libs` when those dirs exist (user-space/WSL2 setup).

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
