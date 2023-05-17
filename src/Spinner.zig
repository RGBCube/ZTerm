const std = @import("std");
const Atomic = std.atomic.Atomic;
const Mutex = Thread.Mutex;
const Thread = std.Thread;
const time = std.time;
const Spinner = @This();

const default_loading_charset = [_][]const u8{ "|", "/", "-", "\\" };
const default_finished_charset = "✓";

loading_charset: []const []const u8 = &default_loading_charset,
loading_message: []const u8 = "",

finished_charset: []const u8 = default_finished_charset,
finished_message: []const u8 = "",

keep_going: Atomic(bool) = Atomic(bool).init(false),
spinner_thread: ?Thread = null,

framerate_ns: u64 = 100 * time.ns_per_ms,

pub fn start(sp: *Spinner) !void {
    sp.keep_going.store(true, .SeqCst);
    sp.spinner_thread = try Thread.spawn(.{}, writer, .{sp});
}

pub fn stop(sp: *Spinner) !void {
    sp.keep_going.store(false, .SeqCst);
    if (sp.spinner_thread) |*thread| thread.join();

    var stdErr = std.io.getStdErr();

    try stdErr.writeAll("\r");
    try stdErr.writeAll(sp.finished_charset);
    try stdErr.writeAll(" ");
    try stdErr.writeAll(sp.finished_message);
}

fn writer(sp: *Spinner) !void {
    var stdErr = std.io.getStdErr();
    var current_char_idx: usize = 0;

    while (true) : (current_char_idx += 1) {
        if (!sp.keep_going.load(.SeqCst)) break;
        if (current_char_idx >= sp.loading_charset.len - 1) current_char_idx = 0;

        try stdErr.writeAll("\r");

        try stdErr.writeAll(sp.loading_charset[current_char_idx]);
        try stdErr.writeAll(" ");
        try stdErr.writeAll(sp.loading_message);

        time.sleep(sp.framerate_ns);
    }
}
