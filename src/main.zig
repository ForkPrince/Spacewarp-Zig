// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");
const tileinfo = @import("./tileinfo.zig");

const rect = rl.Rectangle;

const orig = rl.Vector2.init(0, 0);

const tiles = tileinfo.tiles;

pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1024;
    const screenHeight = 768;

    rl.initWindow(screenWidth, screenHeight, "Spacewarp Editor");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    var tilemap: [16][16]tileinfo.Tile(f32) = undefined;
    for (&tilemap) |*row| {
        for (row) |*tile| {
            tile.* = tiles[0];
        }
    }

    var gesture: rl.Gesture = undefined;
    var touch_position: rl.Vector2 = undefined;

    const textures: rl.Texture2D = rl.loadTexture("./resources/spacewarp_assets.png");
    defer textures.unload();

    var selection: u32 = 0;
    var selected_tile: tileinfo.Tile(f32) = tileinfo.void_tile;

    const transparent = rl.Color.init(255, 255, 255, 127);
    var highlight = rl.Rectangle.init(0, 0, 48, 48);
    var show_highlight: bool = false;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        gesture = rl.getGestureDetected();
        touch_position = rl.getTouchPosition(0);
        if (touch_position.x > 772) {
            const x = @divFloor(touch_position.x - 772, 63);
            const y = @divFloor(touch_position.y, 63);

            if (gesture == rl.Gesture.gesture_tap) {
                selection = @intFromFloat(4 * y + x);
                selected_tile = if (selection < tiles.len) tiles[selection] else tiles[0];

                highlight.width = switch (selected_tile.tile_type) {
                    .end => 2 * 48,
                    else => 48,
                };
                highlight.height = switch (selected_tile.tile_type) {
                    .door => 2 * 48,
                    .end => 2 * 48,
                    else => 48,
                };
            }
            show_highlight = false;
        }

        if (touch_position.x < 768) {
            show_highlight = true;

            const x: usize = @intFromFloat(@divFloor(touch_position.x, 48));
            const y: usize = @intFromFloat(@divFloor(touch_position.y, 48));

            highlight.x = @floatFromInt(x * 48);
            highlight.y = @floatFromInt(y * 48);

            if (gesture == rl.Gesture.gesture_tap) {
                const tile = &tilemap[y][x];
                switch (tile.tile_type) {
                    .door => tilemap[y + 1][x] = tileinfo.void_tile,
                    .end => {
                        tilemap[y + 1][x] = tileinfo.void_tile;
                        tilemap[y][x + 1] = tileinfo.void_tile;
                        tilemap[y + 1][x + 1] = tileinfo.void_tile;
                    },
                    .right => {
                        tilemap[y + 1][x] = tileinfo.void_tile;
                        tilemap[y][x - 1] = tileinfo.void_tile;
                        tilemap[y + 1][x - 1] = tileinfo.void_tile;
                    },
                    .bottom => {
                        tilemap[y - 1][x] = tileinfo.void_tile;
                        if (x < 15 and tilemap[y][x + 1].tile_type == tileinfo.TileType.corner) {
                            tilemap[y][x + 1] = tileinfo.void_tile;
                            tilemap[y - 1][x + 1] = tileinfo.void_tile;
                        }
                    },
                    else => {},
                }
                switch (selected_tile.tile_type) {
                    .door => if (y + 1 < tilemap.len) {
                        tile.* = selected_tile;
                        tilemap[y + 1][x] = tileinfo.bottom_tile;
                    },
                    .end => if (y + 1 < tilemap.len and x + 1 < tilemap[y].len) {
                        tile.* = selected_tile;
                        tilemap[y + 1][x] = tileinfo.bottom_tile;
                        tilemap[y][x + 1] = tileinfo.right_tile;
                        tilemap[y + 1][x + 1] = tileinfo.corner_tile;
                    },
                    else => tile.* = selected_tile,
                }
            }
        }
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangle(768, 0, 4, 768, rl.Color.dark_gray);

        for (tiles, 0..) |tile, i| {
            const x: LargerInt(isize) = 780 + 63 * @mod(i, 4);
            const y: LargerInt(isize) = 8 + 63 * @divFloor(i, 4);
            const position = rect.init(@floatFromInt(x), @floatFromInt(y), 48, 48);

            if (i == selection) rl.drawRectangle(@truncate(x - 4), @truncate(y - 4), 56, 56, rl.Color.white);
            tile.draw(textures, position);
        }

        for (tilemap, 0..) |row, y| {
            for (row, 0..) |tile, x| {
                const width: f32 = switch (tile.tile_type) {
                    .end => 48 * 2,
                    else => 48,
                };
                const height: f32 = switch (tile.tile_type) {
                    .door => 48 * 2,
                    .end => 48 * 2,
                    else => 48,
                };
                tile.draw(textures, rect.init(@floatFromInt(x * 48), @floatFromInt(y * 48), width, height));
            }
        }

        if (show_highlight) rl.drawRectangleRec(highlight, transparent);
        //----------------------------------------------------------------------------------
    }
}

fn LargerInt(comptime T: type) type {
    return @Type(.{
        .Int = .{
            .bits = @typeInfo(T).Int.bits + 1,
            .signedness = @typeInfo(T).Int.signedness,
        },
    });
}
