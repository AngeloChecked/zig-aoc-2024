const std = @import("std");
const Order = std.math.Order;
const ArrayList = std.ArrayList;
const PriorityDequeue = std.PriorityDequeue;
const Allocator = std.mem.Allocator;

const AocError = error{SplitError};

fn lessThanComparison(context: void, a: u32, b: u32) Order {
    _ = context;
    return std.math.order(a, b);
}

pub fn run(allocator: Allocator, input: []u8) !u32 {
    var leftBuffer = PriorityDequeue(u32, void, lessThanComparison).init(allocator, {});
    var rightBuffer = PriorityDequeue(u32, void, lessThanComparison).init(allocator, {});
    defer leftBuffer.deinit();
    defer rightBuffer.deinit();

    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var lineParts = std.mem.splitSequence(u8, line, "   ");
        const leftPart = lineParts.next() orelse {
            return AocError.SplitError;
        };
        const left = try std.fmt.parseInt(u32, leftPart, 10);
        try leftBuffer.add(left);
        const rightPart = lineParts.next() orelse {
            return AocError.SplitError;
        };
        const right = try std.fmt.parseInt(u32, rightPart, 10);
        try rightBuffer.add(right);
    }
    var distanceSum: u32 = 0;
    while (leftBuffer.len > 0) {
        const minLeft = leftBuffer.removeMin();
        const minRight = rightBuffer.removeMin();
        const distance = @max(minLeft, minRight) - @min(minLeft, minRight);
        distanceSum += distance;
    }

    return distanceSum;
}
