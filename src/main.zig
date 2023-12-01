const std = @import("std");
const clap = @import("clap");
const mem = std.mem;
const os = std.os;
const fs = std.fs;
const io = std.io;
const heap = std.heap;

fn takeInput(reader: anytype, str: *[]u8) !void {
    var input: [1024]u8 = undefined;
    str.* = try reader.readUntilDelimiter(&input, '\n');
}

fn printDir(writer: anytype) !void {
    var buf: [1024]u8 = undefined;
    const cwd = try os.getcwd(&buf);
    try writer.print("\nDir: {s}", .{cwd});
}

fn processString(str: []const u8, parsed: [][]const u8) void {
    var i: u8 = 0;
    var si = mem.splitAny(u8, str, " ");

    while (i < 100) : (i += 1) {
        if (si.next()) |next| {
            parsed[i] = next;
        } else {
            break;
        }
    }
}

pub fn main() !void {
    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();
    var parsed: [100][]const u8 = undefined;

    try stdout.print("Enter something: ", .{});
    var in: []u8 = undefined;
    try takeInput(stdin, &in);

    try stdout.print("Entered: {s}\n", .{in});
    processString("This is a test", &parsed);
    try printDir(stdout);
    if (parsed[0].len > 0) try stdout.print("\nFirst parsed: {s}", .{parsed[0]});
}
