const std = @import("std");

pub fn Closure(comptime closure: type) type {
    const FnTp = @TypeOf(closure.call);
    const RetType = @typeInfo(FnTp).@"fn".return_type orelse @panic("Could not find function return type!");

    return struct {
        target: closure,
        callback: FnTp,

        pub fn init(c: closure) @This() {
            return .{
                .target = c,
                .callback = closure.call,
            };
        }

        pub fn invoke(self: @This()) RetType {
            return self.callback(self.target);
        }
    };
}
