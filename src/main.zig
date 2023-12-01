const std = @import("std");
const clap = @import("clap");
const mem = std.mem;
const os = std.os;
const fs = std.fs;
const io = std.io;
const heap = std.heap;
const proc = std.process;

fn takeInput(reader: anytype, str: *[]u8) !void {
    var input: [1024]u8 = undefined;
    str.* = try reader.readUntilDelimiter(&input, '\n');
}

fn printDir(writer: anytype) !void {
    var buf: [1024]u8 = undefined;
    const cwd = try proc.getCwd(&buf);
    try writer.print("\nDir: {s}", .{cwd});
}

fn processString(allocator: mem.Allocator, str: []const u8) ![][]const u8 {
    var i: usize = 0;
    var si = mem.splitAny(u8, str, " ");
    var p = try allocator.alloc([]const u8, 100);
    defer allocator.free(p);
    while (i < 100) : (i += 1) {
        if (si.next()) |next| {
            p[i] = next;
        } else {
            break;
        }
    }
    const ret = try allocator.alloc([]const u8, i);
    mem.copy([]const u8, ret, p[0..i]);

    return ret;
}

fn execArgs(allocator: mem.Allocator, args: [][]const u8) !void {
    const result = proc.execv(allocator, args);

    std.debug.print("\n{any}", .{result});
}

pub fn main() !void {
    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();
    const child_allocator = heap.c_allocator;
    var allocator = heap.ArenaAllocator.init(child_allocator);
    defer allocator.deinit();

    try stdout.print("Enter something: ", .{});
    var in: []u8 = undefined;
    try takeInput(stdin, &in);

    try stdout.print("Entered: {s}\n", .{in});

    const cwd = try proc.getCwdAlloc(allocator.allocator());
    defer allocator.allocator().free(cwd);
    const cmd = try mem.concat(allocator.allocator(), u8, &[_][]const u8{ "/bin/ls ", cwd });
    const parsed: [][]const u8 = try processString(allocator.allocator(), cmd);
    defer allocator.allocator().free(parsed);
    try printDir(stdout);

    if (parsed[0].len > 0) try stdout.print("\nFirst parsed: {s}\n", .{parsed[0]});
    const alloc = allocator.allocator();
    try execArgs(alloc, parsed);
}
