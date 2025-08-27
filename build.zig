const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    _ = b.addModule("zstdy", .{
        .root_source_file = b.path("src/zstdy.zig"),
    });
}
