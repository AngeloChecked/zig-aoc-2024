const std = @import("std");
const Order = std.math.Order;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const PriorityDequeue = std.PriorityDequeue;
const Allocator = std.mem.Allocator;
const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

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

pub fn day2run(allocator: Allocator, input: []u8) !u32 {
    var reports = ArrayList(ArrayList(u32)).init(allocator);
    defer reports.deinit();
    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var lineParts = std.mem.splitSequence(u8, line, " ");

        var report = ArrayList(u32).init(allocator);
        while (lineParts.next()) |part| {
            if (!std.mem.eql(u8, part, "")) {
                const level = try std.fmt.parseInt(u32, part, 10);
                try report.append(level);
            }
        }
        try reports.append(report);
    }

    var safeReportNum: u32 = 0;
    for (reports.items) |report| {
        const isSafe = isSafeReport(report.items);
        if (isSafe) {
            safeReportNum += 1;
        }
        report.deinit();
    }

    return safeReportNum;
}

fn isSafeReport(report: []u32) bool {
    var previousOperationType: ?bool = null;

    for (0..(report.len - 1)) |i| {
        const current: i33 = @intCast(report[i]);
        const next: i33 = @intCast(report[i + 1]);
        const operationDifference: i33 = current - next;
        if (operationDifference < -3 or operationDifference > 3 or operationDifference == 0) {
            return false;
        }
        const currentOperationType = operationDifference > 0;
        if (previousOperationType != null and (previousOperationType != currentOperationType)) {
            return false;
        }
        previousOperationType = currentOperationType;
    }
    return true;
}

test "is report safe" {
    var input = [_]u32{ 1, 2, 3, 4 };
    var castedInput: []u32 = &input;
    try expect(isSafeReport(castedInput));
    input = [_]u32{ 1, 2, 4, 7 };
    try expect(isSafeReport(castedInput));
    input = [_]u32{ 7, 6, 4, 1 };
    try expect(isSafeReport(castedInput));
    input = [_]u32{ 1, 5, 6, 7 };
    try expect(!isSafeReport(castedInput));
    input = [_]u32{ 1, 1, 1, 1 };
    try expect(!isSafeReport(castedInput));
    input = [_]u32{ 15, 10, 5, 0 };
    try expect(!isSafeReport(castedInput));
}
