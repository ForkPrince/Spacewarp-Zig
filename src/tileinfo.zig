const rl = @import("raylib");

pub const Color = enum { yellow, red, blue };

pub const TileType = union(enum) {
    wall,
    fire,
    door: Color,
    button: Color,
    key: Color,
    end,
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
            // const position = rl.Rectangle.init(pos.x, pos.y, source.width, source.height);
            rl.drawTexturePro(texture, source, pos, rl.Vector2.init(0, 0), 0, rl.Color.white);
        }
    };
}

// yeah this is probably gonna change in the future but i don't feel like reorganizing the png file
pub const tiles = [_]Tile(f32){
    Tile(f32).init(0, 0, TileType.none),
    Tile(f32).init(4, 0, TileType.wall),
    Tile(f32).init(5, 0, TileType.wall),
    Tile(f32).init(6, 0, TileType.wall),
    Tile(f32).init(7, 0, TileType.wall),
    Tile(f32).init(4, 1, TileType.wall),
    Tile(f32).init(5, 1, TileType.wall),
    Tile(f32).init(6, 1, TileType.wall),
    Tile(f32).init(7, 1, TileType.wall),
    Tile(f32).init(2, 2, TileType.wall),
    Tile(f32).init(3, 2, TileType.wall),
    Tile(f32).init(4, 2, TileType.wall),
    Tile(f32).init(5, 2, TileType.wall),
    Tile(f32).init(2, 3, TileType.wall),
    Tile(f32).init(3, 3, TileType.wall),
    Tile(f32).init(4, 3, TileType.wall),
    Tile(f32).init(5, 3, TileType.wall),
    Tile(f32).init(0, 2, TileType.fire),
    Tile(f32).init(1, 2, TileType.fire),
    Tile(f32).init(0, 3, TileType.fire),
    Tile(f32).init(1, 3, TileType.fire),
    Tile(f32).init(0, 4, TileType.end),
    Tile(f32).init(4, 4, TileType{ .door = Color.yellow }),
    Tile(f32).init(5, 4, TileType{ .door = Color.red }),
    Tile(f32).init(6, 4, TileType{ .door = Color.blue }),
    Tile(f32).init(7, 4, TileType{ .key = Color.yellow }),
    Tile(f32).init(7, 5, TileType{ .key = Color.red }),
    Tile(f32).init(7, 6, TileType{ .key = Color.blue }),
    Tile(f32).init(4, 6, TileType{ .button = Color.yellow }),
    Tile(f32).init(5, 6, TileType{ .button = Color.red }),
    Tile(f32).init(6, 6, TileType{ .button = Color.blue }),
};
