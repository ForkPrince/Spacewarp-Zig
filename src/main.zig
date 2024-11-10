// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");
const tileinfo = @import("./tileinfo.zig");

const rect = rl.Rectangle;

const orig = rl.Vector2.init(0, 0);

const tiles = tileinfo.tiles;

    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1024;
    const screenHeight = 768;

    rl.initWindow(screenWidth, screenHeight, "Spacewarp Editor");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    var gesture: rl.Gesture = undefined;
    var touch_position: rl.Vector2 = undefined;

    const textures: rl.Texture2D = rl.loadTexture("./resources/spacewarp_assets.png");
    defer textures.unload();

    const pos = rect.init(0, 0, 48, 48);
    const frame = rect.init(8, 0, 8, 8);

    var selection: u32 = 0;
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

            if (gesture == rl.Gesture.gesture_tap) selection = @intFromFloat(4 * y + x);
        }
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangle(768, 0, 4, 768, rl.Color.dark_gray);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);

        for (tiles, 0..) |tile, i| {
            const x: LargerInt(isize) = 780 + 63 * @mod(i, 4);
            const y: LargerInt(isize) = 8 + 63 * @divFloor(i, 4);
            const position = rect.init(@floatFromInt(x), @floatFromInt(y), 48, 48);

            if (i == selection) rl.drawRectangle(@truncate(x - 4), @truncate(y - 4), 56, 56, rl.Color.white);
            tile.draw(textures, position);
        }

        rl.drawTexturePro(textures, frame, pos, orig, 0, rl.Color.white);
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
