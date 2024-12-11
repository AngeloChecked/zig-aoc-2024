const std = @import("std");
const aoc1 = @import("aoc1.zig");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

fn readFileToBuffer(allocator: Allocator, fname: []const u8) ![]u8 {
    const f = try std.fs.cwd().openFile(fname, .{});
    defer f.close();

    const f_len = try f.getEndPos();
    var buf = try allocator.alloc(u8, f_len);
    errdefer allocator.free(buf);

    _ = try f.readAll(buf);
    return buf;
}

test "testing simple sum" {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const input = try readFileToBuffer(allocator, "inputs/1.txt");
    defer allocator.free(input);

    const output = try aoc1.run(allocator, input);
    const output2 = try aoc1.run2(allocator, input);

    try expectEqual(@as(u32, 3569916), output);
    std.debug.print("===>{d}", .{output2});
    try expectEqual(@as(u32, 26407426), output2);
}
