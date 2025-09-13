const std = @import("std");

pub const String = struct {
    const Self = @This();
    slice: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator, slc: []const u8) !Self {
        const dupedSlice = try alloc.dupe(u8, slc);
        return Self{
           .slice = dupedSlice,
           .allocator = alloc,
        };
    }

    pub fn add(self: Self, new: []const u8) Self {
        defer self.deinit() catch @panic("Failed to free unmutated string!");

        const newSlice = self.allocator.alloc(u8, self.slice.len + new.len) catch @panic("Could not add to string");
        
        std.mem.copyForwards(u8, newSlice, self.slice);
        std.mem.copyForwards(u8, newSlice[self.slice.len..], new);

        return Self{
            .slice = newSlice,
            .allocator = self.allocator,
        };
    }

    pub fn addStr(self: Self, new: Self) Self {
        defer self.deinit() catch @panic("Failed to free unmutated string!");

        const newSlice = self.allocator.alloc(u8, self.slice.len + new.slice.len) catch @panic("Could not add to string");
        
        std.mem.copyForwards(u8, newSlice, self.slice);
        std.mem.copyForwards(u8, newSlice[self.slice.len..], new.slice);

        return Self{
            .slice = newSlice,
            .allocator = self.allocator,
        };
    }

    pub fn addNoFree(self: Self, new: []const u8) Self {
        const newSlice = self.allocator.alloc(u8, self.slice.len + new.len) catch @panic("Could not add to string!");
        
        std.mem.copyForwards(u8, newSlice, self.slice);
        std.mem.copyForwards(u8, newSlice[self.slice.len..], new);

        return Self{
            .slice = newSlice,
            .allocator = self.allocator,
        };
    }

    pub fn contains(self: Self, pattern: []const u8) bool {
        return std.mem.containsAtLeast(u8, self.slice, 1, pattern);
    }

    pub fn ansi(self: Self, code: []const u8) Self {
        defer self.deinit() catch @panic("Failed to free unmutated string!");

        var header = Self.init(self.allocator, "\x1B[38;5;") catch @panic("Could not allocate header");
        header = header.add(code).add("m");
        header = header.add(self.slice);
        header = header.add("\x1B[0m");

        return header;
    }

    pub fn bold(self: Self) Self {
        defer self.deinit() catch @panic("Failed to free unmutated string!");

        var header = Self.init(self.allocator, "\x1B[1m") catch @panic("Could not allocate header");
        header = header.add(self.slice);
        header = header.add("\x1B[0m");

        return header;
    }

    pub fn deinit(self: Self) !void {
        self.allocator.free(self.slice);
    }
};

pub fn hash(str: []const u8) u64 {
    var hasher = std.hash.Fnv1a_64.init();
    hasher.update(str);

    return hasher.final();
}

test "String.add()" {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gp.allocator();
    defer _ = gp.deinit();

    var str = try String.init(alloc, "Hello, ");
    defer str.deinit() catch @panic("Failed to free string!");

    str = str.add("World!");

    std.debug.print("{s}\n", .{str.slice});
}

test "String.contains()" {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gp.allocator();
    defer _ = gp.deinit();

    var str = try String.init(alloc, "Hello, World!");
    defer str.deinit() catch @panic("Failed to free string!");

    if(str.contains("World!")) {
        std.debug.print("String contains \"World!\"\n", .{});
    }
}

test "hash()" {
    const str = "Hi!";
    const h = hash(str);
    
    std.debug.print("Hash is: {d}\n", .{h});
}

test "String Colors" {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gp.allocator();
    defer _ = gp.deinit();

    var str = try String.init(alloc, "Hello, World!");
    defer str.deinit() catch @panic("Could not free string!");

    str = str.ansi("127").bold();
    
    std.debug.print("{s}\n", .{str.slice});
}
