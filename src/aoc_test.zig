const std = @import("std");
const aoc = @import("aoc.zig");
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

test "aoc day 1" {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const input = try readFileToBuffer(allocator, "inputs/1.txt");
    defer allocator.free(input);

    const output = try aoc.run(allocator, input);
    const output2 = try aoc.run2(allocator, input);

    try expectEqual(@as(u32, 3569916), output);
    try expectEqual(@as(u32, 26407426), output2);
}

test "aoc day 2" {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const input = try readFileToBuffer(allocator, "inputs/2.txt");
    defer allocator.free(input);

    const output = try aoc.day2run(allocator, input, 0);
    const output2 = try aoc.day2run(allocator, input, 1);

    std.log.warn("{any}", .{output2});

    try expectEqual(@as(u32, 559), output);
    try expectEqual(@as(u32, 601), output2);
}
