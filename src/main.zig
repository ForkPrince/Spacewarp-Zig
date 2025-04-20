// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");

const bit16 = 32_768;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 500;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var squarePos = rl.Vector2.init(0, 0);
    var movement = rl.Vector2.init(2, 1);
    const square = rl.Vector2.init(100, 100);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        squarePos = squarePos.add(movement);

        if (squarePos.x <= 0 or squarePos.x + square.x >= screenWidth) movement.x *= -1;
        if (squarePos.y <= 0 or squarePos.y + square.y >= screenHeight) movement.y *= -1;

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);

        rl.drawRectangleV(squarePos, square, rl.Color.black);
        //----------------------------------------------------------------------------------
    }
}

fn loadFile(filename: []const u8) ![16][16]tileinfo.Tile(f32) {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var tile_list: [16][16]tileinfo.Tile(f32) = undefined;
    for (&tile_list) |*row| {
        for (row) |*tile| {
            var item: tileinfo.Tile(f32) = undefined;
            _ = try file.readAll(std.mem.asBytes(&item));
            tile.* = item;
        }
    }
    return tile_list;
}
