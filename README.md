# Raylib Quickstart (Zig)

A simple cross-platform template for setting up a project with raylib and raygui in Zig.

## Requirements
- [Zig](https://ziglang.org/) (0.16.0 or newer)
- Desktop platforms supported:
  - macOS
  - Linux (requires X11 dev headers and libs, e.g. `libx11-dev`, `libxcursor-dev`, `libxrandr-dev`, `libxinerama-dev`, `libxi-dev`, `libgl1-mesa-dev`, `libasound2-dev`)
  - Windows

## Quick Start

### Build and Run
Using `make`:
```bash
make run
```
Or directly with the Zig CLI:
```bash
zig build run
```

### Build Only
Using `make`:
```bash
# Debug build (default)
make
# or
make debug

# Release build
make release
```
Or directly with the Zig CLI:
```bash
# Debug build (default)
zig build

# Release build
zig build -Doptimize=ReleaseFast
```

The compiled binary will be located in `zig-out/bin/raylib_quickstart`.

### Clean Build Artifacts
```bash
make clean
```
or:
```bash
rm -rf zig-out zig-cache .zig-cache
```

## Supported Platforms and Backends
Quickstart supports the main 3 desktop platforms:
- Windows
- Linux
- macOS

### Build Options
Zig build options can be passed via `ZIG_BUILD_ARGS` or directly to `zig build`:

- **Platform backend**: `-Dplatform=<backend>`
  - `glfw` (default): Native windowed desktop backend (GLFW + OpenGL)
  - `memory`: Headless software rendering (useful for testing or environments without a display server)
- **OpenGL version**: `-Dopengl_version=<version>`
  - `gl_3_3` (default): OpenGL 3.3
  - `gl_2_1`: OpenGL 2.1
  - `gl_1_1`: OpenGL 1.1
  - `gl_4_3`: OpenGL 4.3
  - `gles_2`: OpenGLES 2.0
  - `gles_3`: OpenGLES 3.0
  - `gl_soft`: Software rasterizer (use with `-Dplatform=memory`)

Example for headless software rendering:
```bash
zig build -Dplatform=memory -Dopengl_version=gl_soft
```

## Project Structure
- `src/main.zig`: Application entry point featuring raylib and raygui example code
- `resources/`: Asset directory (contains textures, audio, fonts, etc.)
- `build.zig`: Zig build script configuring `raylib-zig` and compilation options
- `build.zig.zon`: Zig package manifest declaring dependencies (`raylib-zig`)
- `Makefile`: Convenience wrapper for common build tasks

## Working Directories and Resources
The template includes a `searchAndSetResourceDir` helper in `src/main.zig` that checks the current working directory, application binary directory, and parent folders for the `resources` directory and sets it as the working directory. This ensures assets like `resources/wabbit_alpha.png` load reliably regardless of where the binary is executed.

## Writing Your Code
Start editing `src/main.zig` to build your game or application. The project includes both `raylib` and `raygui` module imports:

```zig
const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub fn main() !void {
    rl.initWindow(800, 600, "My Game");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(.black);
        rl.drawText("Hello from Zig!", 200, 200, 20, .white);
        rl.endDrawing();
    }
}
```

## Adding Dependencies
To add external Zig packages, add them to `build.zig.zon` and import them in `build.zig` using the Zig package manager.

## VS Code Users
VS Code configuration files are provided in `.vscode/`:
- Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on macOS) to run the default build task (`zig build`).
- Press `F5` to start debugging with the configured launch profile.

## License
Raylib Quickstart is marked with CC0 1.0. To view a copy of this license, visit https://creativecommons.org/publicdomain/zero/1.0/

