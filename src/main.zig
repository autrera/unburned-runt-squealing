const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub fn main() !void {
    // Tell the window to use vsync and work on high DPI displays
    rl.setConfigFlags(.{ .vsync_hint = true, .window_highdpi = true });

    // Create the window and OpenGL context
    rl.initWindow(800, 600, "Hello Raylib");
    defer rl.closeWindow();

    // Utility function to find the resources folder and set it as the current working directory
    _ = searchAndSetResourceDir("resources");

    // Load a texture from the resources directory
    const wabbit = try rl.loadTexture("wabbit_alpha.png");
    defer rl.unloadTexture(wabbit);

    var counter: i32 = 0;
    var show_message = false;

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Update
        // (no per-frame update needed beyond raygui interaction)

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        // Setup the back buffer for drawing (clear color and depth buffers)
        rl.clearBackground(.black);

        // Draw some text using the default font
        rl.drawText("Hello Raylib", 200, 200, 20, .white);

        // Draw our texture to the screen
        rl.drawTexture(wabbit, 400, 200, .white);

        // --- raygui integration ---
        // Simple button that increments a counter
        if (rg.button(rl.Rectangle.init(10, 10, 140, 30), "Click me!")) {
            counter += 1;
            show_message = true;
        }

        // Label showing counter value
        _ = rg.label(rl.Rectangle.init(10, 50, 200, 20), rl.textFormat("Clicks: %d", .{counter}));

        // Slider demo
        var slider_value: f32 = @floatFromInt(counter);
        _ = rg.slider(rl.Rectangle.init(10, 80, 200, 20), "0", "10", &slider_value, 0, 10);

        // Status bar
        _ = rg.statusBar(rl.Rectangle.init(0, 580, 800, 20), "raygui integrated with raylib-zig");

        if (show_message and counter > 0) {
            const result = rg.messageBox(
                rl.Rectangle.init(300, 250, 200, 100),
                "Hello",
                "Button clicked!",
                "OK",
            );
            if (result >= 0) show_message = false;
        }
    }
}

/// Looks for the specified resource dir in several common locations
/// The working dir, the app dir, and up to 3 levels above the app dir.
/// Searches for the specified resource directory in several common locations.
fn searchAndSetResourceDir(folderName: [:0]const u8) bool {
    var buf: [1024:0]u8 = undefined;

    if (rl.directoryExists(folderName)) {
        const cwd = rl.getWorkingDirectory();
        const path = std.fmt.bufPrintZ(&buf, "{s}/{s}", .{ cwd, folderName }) catch return false;
        _ = rl.changeDirectory(path);
        return true;
    }

    const appDir = rl.getApplicationDirectory();

    const dir1 = std.fmt.bufPrintZ(&buf, "{s}{s}", .{ appDir, folderName }) catch return false;
    if (rl.directoryExists(dir1)) {
        _ = rl.changeDirectory(dir1);
        return true;
    }

    const dir2 = std.fmt.bufPrintZ(&buf, "{s}../{s}", .{ appDir, folderName }) catch return false;
    if (rl.directoryExists(dir2)) {
        _ = rl.changeDirectory(dir2);
        return true;
    }

    const dir3 = std.fmt.bufPrintZ(&buf, "{s}../../{s}", .{ appDir, folderName }) catch return false;
    if (rl.directoryExists(dir3)) {
        _ = rl.changeDirectory(dir3);
        return true;
    }

    const dir4 = std.fmt.bufPrintZ(&buf, "{s}../../../{s}", .{ appDir, folderName }) catch return false;
    if (rl.directoryExists(dir4)) {
        _ = rl.changeDirectory(dir4);
        return true;
    }

    return false;
}
