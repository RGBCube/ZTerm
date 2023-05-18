const std = @import("std");
const Atomic = std.atomic.Atomic;
const Mutex = Thread.Mutex;
const Thread = std.Thread;
const time = std.time;
const Spinner = @This();

// Must be only accessed when thread_lock is held by the current thread.
charset: []const []const u8 = &[_][]const u8{ "|", "/", "-", "\\" },
message: []const u8 = "",

keep_going: Atomic(bool) = Atomic(bool).init(false),
spinner_thread: ?Thread = null,
thread_lock: Mutex = Mutex{},

framerate_ns: u64 = 100 * time.ns_per_ms,

pub fn start(sp: *Spinner) !void {
    sp.keep_going.store(true, .SeqCst);
    sp.spinner_thread = try Thread.spawn(.{}, writer, .{sp});
}

pub fn stop(sp: *Spinner, config: struct {
    charset: ?[]const u8 = null,
    message: ?[]const u8 = null,
}) !void {
    sp.keep_going.store(false, .SeqCst);
    (sp.spinner_thread orelse unreachable).join();

    var stdErr = std.io.getStdErr();

    sp.thread_lock.lock();
    defer sp.thread_lock.unlock();

    try stdErr.writeAll("\r");
    try stdErr.writeAll(config.charset orelse sp.charset[0]);
    try stdErr.writeAll(" ");
    try stdErr.writeAll(config.message orelse sp.message);
    try stdErr.writeAll("\n");
}

pub fn setCharset(sp: *Spinner, charset: []const []const u8) void {
    sp.thread_lock.lock();
    defer sp.thread_lock.unlock();

    sp.charset = charset;
}

pub fn setMessage(sp: *Spinner, message: []const u8) void {
    sp.thread_lock.lock();
    defer sp.thread_lock.unlock();

    sp.message = message;
}

fn writer(sp: *Spinner) !void {
    var stdErr = std.io.getStdErr();
    var current_char_idx: usize = 0;

    while (true) : (current_char_idx += 1) {
        if (!sp.keep_going.load(.SeqCst)) return;
        if (current_char_idx >= sp.charset.len - 1) current_char_idx = 0;

        sp.thread_lock.lock();
        try stdErr.writeAll(sp.charset[current_char_idx]);
        try stdErr.writeAll(" ");
        try stdErr.writeAll(sp.message);
        try stdErr.writeAll("\r");
        sp.thread_lock.unlock();

        time.sleep(sp.framerate_ns);
    }
}
