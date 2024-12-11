const std = @import("std");
const Order = std.math.Order;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
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

pub fn run2(allocator: Allocator, input: []u8) !u32 {
    var leftBuffer = ArrayList(u32).init(allocator);
    var rightBuffer = AutoHashMap(u32, u32).init(allocator);
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
        try leftBuffer.append(left);
        const rightPart = lineParts.next() orelse {
            return AocError.SplitError;
        };
        const right = try std.fmt.parseInt(u32, rightPart, 10);
        const value = rightBuffer.get(right) orelse 0;
        try rightBuffer.put(right, value + 1);
    }
    var similaritySum: u32 = 0;
    while (leftBuffer.popOrNull()) |num| {
        const similarity = rightBuffer.get(num) orelse 0;
        similaritySum += num * similarity;
    }
    return similaritySum;
}
