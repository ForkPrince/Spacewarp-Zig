// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");
const rect = rl.Rectangle;

const orig = rl.Vector2.init(0, 0);

const tiles = [_]Tile{
    Tile.init(0, 0), // Empty
    Tile.init(4, 0), // Wall
    Tile.init(5, 0), // Wall
    Tile.init(6, 0), // Wall
    Tile.init(7, 0), // Wall
    Tile.init(4, 1), // Wall
    Tile.init(5, 1), // Wall
    Tile.init(6, 1), // Wall
    Tile.init(7, 1), // Wall
    Tile.init(2, 2), // Wall
    Tile.init(3, 2), // Wall
    Tile.init(4, 2), // Wall
    Tile.init(5, 2), // Wall
    Tile.init(2, 3), // Wall
    Tile.init(3, 3), // Wall
    Tile.init(4, 3), // Wall
    Tile.init(5, 3), // Wall
    Tile.init(0, 2), // Fire
    Tile.init(1, 2), // Fire
    Tile.init(0, 3), // Fire
    Tile.init(1, 3), // Fire
    Tile.initBig(0, 4, 2, 2), // Ship
    Tile.initBig(4, 4, 1, 2), // Yellow Door
    Tile.initBig(5, 4, 1, 2), // Red Door
    Tile.initBig(6, 4, 1, 2), // Blue Door
    Tile.init(7, 4), // Yellow Key
    Tile.init(7, 5), // Red Key
    Tile.init(7, 6), // Blue Key
    Tile.init(4, 6), // Yellow Button
    Tile.init(5, 6), // Red Button
    Tile.init(6, 6), // Blue Button
};

pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1024;
    const screenHeight = 768;

    rl.initWindow(screenWidth, screenHeight, "Spacewarp Editor");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const textures: rl.Texture2D = rl.loadTexture("./resources/spacewarp_assets.png");
    defer textures.unload();

    const pos = rect.init(0, 0, 48, 48);
    const frame = rect.init(8, 0, 8, 8);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangle(768, 0, 4, 768, rl.Color.dark_gray);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);

        for (tiles, 0..) |tile, i| {
            // const position = rect.init(@floatFromInt(780 + 63 * i), 4, 48, 48);
            const position = rect.init(@floatFromInt(780 + 63 * @mod(i, 4)), @floatFromInt(4 + 63 * @divFloor(i, 4)), 48, 48);
            // rl.drawTexturePro(textures, frame, position, orig, 0, rl.Color.white);
            tile.draw(textures, position);
        }

        rl.drawTexturePro(textures, frame, pos, orig, 0, rl.Color.white);
        //----------------------------------------------------------------------------------
    }
}

const Tile = struct {
    source: rect,

    pub fn init(x: f32, y: f32) Tile {
        return Tile{ .source = rect.init(x * 8, y * 8, 8, 8) };
    }

    pub fn initBig(x: f32, y: f32, w: f32, h: f32) Tile {
        return Tile{ .source = rect.init(x * 8, y * 8, w * 8, h * 8) };
    }

    pub fn draw(self: Tile, texture: rl.Texture2D, pos: rect) void {
        rl.drawTexturePro(texture, self.source, pos, orig, 0, rl.Color.white);
    }
};
