const std = @import("std");
const zios = @import("zio-s.zig");

pub fn main() !void {
    var gpa_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_alloc.deinit() == .ok);
    const gpa = gpa_alloc.allocator();

    std.debug.print("allocator initialized\n", .{});

    //0 means number of logical CPU cores available
    var server = try zios.Http.init(std.net.Address.initIp4(.{ 0, 0, 0, 0 }, 64000), 0);
    defer server.deinit();

    std.debug.print("server initialized\n", .{});

    try server.run(&gpa);
}
