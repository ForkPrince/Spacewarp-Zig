const rl = @import("raylib");

pub const Color = enum { yellow, red, blue };

pub const TileType = union(enum) {
    wall,
    fire,
    door: Color,
    button: Color,
    key: Color,
    end,
    bottom,
    right,
    corner,
    none,
};

pub fn Tile(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        tile_type: TileType,

        pub fn init(x: T, y: T, tile_type: TileType) Tile(T) {
            return Tile(T){ .x = x * 8, .y = y * 8, .tile_type = tile_type };
        }

        pub fn draw(self: Tile(T), texture: rl.Texture2D, pos: rl.Rectangle) void {
            const source = switch (self.tile_type) {
                .door => rl.Rectangle.init(self.x, self.y, 8, 16),
                .end => rl.Rectangle.init(self.x, self.y, 16, 16),
                else => rl.Rectangle.init(self.x, self.y, 8, 8),
            };
            rl.drawTexturePro(texture, source, pos, rl.Vector2.init(0, 0), 0, rl.Color.white);
        }
    };
}

pub const void_tile = Tile(f32).init(0, 0, TileType.none);
pub const bottom_tile = Tile(f32).init(0, 0, TileType.bottom);
pub const right_tile = Tile(f32).init(0, 0, TileType.right);
pub const corner_tile = Tile(f32).init(0, 0, TileType.corner);

// there doesn't seem to be a better way of doing this, as accessing an array is a runtime operation
pub const tiles = [_]Tile(f32){
    Tile(f32).init(0, 0, TileType.none),
    Tile(f32).init(0, 3, TileType.wall),
    Tile(f32).init(1, 3, TileType.wall),
    Tile(f32).init(2, 3, TileType.wall),
    Tile(f32).init(3, 3, TileType.wall),
    Tile(f32).init(4, 3, TileType.wall),
    Tile(f32).init(5, 3, TileType.wall),
    Tile(f32).init(6, 3, TileType.wall),
    Tile(f32).init(7, 3, TileType.wall),
    Tile(f32).init(8, 3, TileType.wall),
    Tile(f32).init(9, 3, TileType.wall),
    Tile(f32).init(10, 3, TileType.wall),
    Tile(f32).init(11, 3, TileType.wall),
    Tile(f32).init(12, 3, TileType.wall),
    Tile(f32).init(13, 3, TileType.wall),
    Tile(f32).init(14, 3, TileType.wall),
    Tile(f32).init(15, 3, TileType.wall),
    Tile(f32).init(3, 2, TileType.fire),
    Tile(f32).init(4, 2, TileType.fire),
    Tile(f32).init(5, 2, TileType.fire),
    Tile(f32).init(6, 2, TileType.fire),
    Tile(f32).init(0, 4, TileType{ .key = Color.yellow }),
    Tile(f32).init(1, 4, TileType{ .key = Color.red }),
    Tile(f32).init(2, 4, TileType{ .key = Color.blue }),
    Tile(f32).init(0, 5, TileType{ .button = Color.yellow }),
    Tile(f32).init(1, 5, TileType{ .button = Color.red }),
    Tile(f32).init(2, 5, TileType{ .button = Color.blue }),
    Tile(f32).init(0, 6, TileType{ .door = Color.yellow }),
    Tile(f32).init(1, 6, TileType{ .door = Color.red }),
    Tile(f32).init(2, 6, TileType{ .door = Color.blue }),
    Tile(f32).init(3, 6, TileType.end),
};
