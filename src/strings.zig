const std = @import("std");

// pub fn String(slc: []const u8) type {
//     return struct {
//         const Self = @This();
//         slice: []const u8,
//         allocator: std.mem.Allocator,
//
//         pub fn init(alloc: std.mem.Allocator) !Self {
//             const dupedSlice = try alloc.dupe(u8, slc);
//             return Self{
//                .slice = dupedSlice,
//                .allocator = alloc,
//             };
//         }
//
//         pub fn add(self: Self, new: []const u8) !Self {
//             defer self.deinit() catch @panic("Failed to free unmutated string!");
//
//             const newSlice = try self.allocator.alloc(u8, self.slice.len + new.len);
//             
//             std.mem.copyForwards(u8, newSlice, self.slice);
//             std.mem.copyForwards(u8, newSlice[self.slice.len..], new);
//
//             return Self{
//                 .slice = newSlice,
//                 .allocator = self.allocator,
//             };
//         }
//
//         pub fn addNoFree(self: Self, new: []const u8) !Self {
//             const newSlice = try self.allocator.alloc(u8, self.slice.len + new.len);
//             
//             std.mem.copyForwards(u8, newSlice, self.slice);
//             std.mem.copyForwards(u8, newSlice[self.slice.len..], new);
//
//             return Self{
//                 .slice = newSlice,
//                 .allocator = self.allocator,
//             };
//         }
//
//         pub fn contains(self: Self, pattern: []const u8) bool {
//             return std.mem.containsAtLeast(u8, self.slice, 1, pattern);
//         }
//
//         pub fn deinit(self: Self) !void {
//             self.allocator.free(self.slice);
//         }
//     };
// }

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

    pub fn add(self: Self, new: []const u8) !Self {
        defer self.deinit() catch @panic("Failed to free unmutated string!");

        const newSlice = try self.allocator.alloc(u8, self.slice.len + new.len);
        
        std.mem.copyForwards(u8, newSlice, self.slice);
        std.mem.copyForwards(u8, newSlice[self.slice.len..], new);

        return Self{
            .slice = newSlice,
            .allocator = self.allocator,
        };
    }

    pub fn addNoFree(self: Self, new: []const u8) !Self {
        const newSlice = try self.allocator.alloc(u8, self.slice.len + new.len);
        
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

    str = try str.add("World!");

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
