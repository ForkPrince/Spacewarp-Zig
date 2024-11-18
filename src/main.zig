// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");
const tileinfo = @import("./tileinfo.zig");

const rect = rl.Rectangle;

const orig = rl.Vector2.init(0, 0);

const tiles = tileinfo.tiles;

var difficulty = struct {
    diffs: [4][:0]const u8,
    selection: usize,

    pub fn nextSelection(self: *@This()) void {
        self.selection += 1;
        self.selection = @mod(self.selection, self.diffs.len);
    }

    pub fn getCurrentSelection(self: @This()) [:0]const u8 {
        return self.diffs[self.selection];
    }

    pub fn init() @This() {
        return @This(){ .diffs = [4][:0]const u8{ "easy", "normal", "hard", "lunatic" }, .selection = 0 };
    }
}.init();

var level_number: u8 = 0;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();
    _ = ally;

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

    var saving_file: bool = false;
    var loading_file: bool = false;

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

            if (gesture == rl.Gesture.gesture_tap and !saving_file and !loading_file) {
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
                        if (tilemap[y - 1][x].tile_type == tileinfo.TileType.end) {
                            tilemap[y][x + 1] = tileinfo.void_tile;
                            tilemap[y - 1][x + 1] = tileinfo.void_tile;
                        }
                    },
                    .corner => {
                        tilemap[y - 1][x] = tileinfo.void_tile;
                        tilemap[y][x - 1] = tileinfo.void_tile;
                        tilemap[y - 1][x - 1] = tileinfo.void_tile;
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

        if (rl.isKeyPressed(rl.KeyboardKey.key_s) and !loading_file) saving_file = !saving_file;

        if (saving_file) {
            updateFileDialog(touch_position, gesture);
            if (rl.isKeyPressed(rl.KeyboardKey.key_enter)) {
                const filename = try getSaveFileName();
                try saveFile(filename, tilemap);
                saving_file = false;
            }
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_l) and !saving_file) loading_file = !loading_file;

        if (loading_file) {
            updateFileDialog(touch_position, gesture);
            if (rl.isKeyPressed(rl.KeyboardKey.key_enter)) {
                const filename = try getSaveFileName();
                tilemap = loadFile(filename) catch |err| switch (err) {
                    error.FileNotFound => tilemap,
                    else => return err,
                };
                loading_file = false;
            }
        }

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangle(768, 0, 4, 768, rl.Color.dark_gray);

        for (tiles, 0..) |tile, i| {
            const x: i32 = @intCast(780 + 63 * @mod(i, 4));
            const y: i32 = @intCast(8 + 63 * @divFloor(i, 4));
            const position = rect.init(@floatFromInt(x), @floatFromInt(y), 48, 48);

            if (i == selection) rl.drawRectangle(x - 4, y - 4, 56, 56, rl.Color.white);
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

        if (saving_file or loading_file) {
            drawFileDialog();
        }
        //----------------------------------------------------------------------------------
    }
}

fn getSaveFileName() ![:0]const u8 {
    var buf = [_]u8{undefined} ** 30;
    return try std.fmt.bufPrintZ(&buf, "resources/save_{s}{d}.dat", .{ difficulty.getCurrentSelection(), level_number });
}

fn updateFileDialog(touch_position: anytype, gesture: anytype) void {
    if (touch_position.x >= 284 and touch_position.x < 420 and touch_position.y >= 364 and touch_position.y <= 386 and gesture == rl.Gesture.gesture_tap) {
        difficulty.nextSelection();
    }
    if (rl.isKeyPressed(rl.KeyboardKey.key_i)) level_number = @addWithOverflow(level_number, 1)[0];
    if (rl.isKeyPressed(rl.KeyboardKey.key_d)) level_number = @subWithOverflow(level_number, 1)[0];
}

fn drawFileDialog() void {
    const rec = rect.init(136, 256, 512, 256);
    rl.drawRectangleRec(rec, rl.Color.light_gray);
    rl.drawText("Input file path", 307, 264, 24, rl.Color.dark_gray);

    rl.drawRectangle(152, 359, 480, 50, rl.Color.dark_gray);

    rl.drawText("save_", 160, 364, 40, rl.Color.white);
    rl.drawText(difficulty.getCurrentSelection(), 280, 364, 40, rl.Color.white);

    var buf: [4]u8 = undefined;
    const lvl_number = std.fmt.bufPrintZ(&buf, "{d}", .{level_number}) catch unreachable;

    rl.drawText(lvl_number, 420, 364, 40, rl.Color.white);

    rl.drawText(".dat", 550, 364, 40, rl.Color.white);

    rl.drawText("Press enter...", 320, 480, 24, rl.Color.dark_gray);
}

fn saveFile(filename: []const u8, items: anytype) !void {
    const file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    for (items) |column| {
        for (column) |item| {
            try file.writeAll(std.mem.asBytes(&item));
        }
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
