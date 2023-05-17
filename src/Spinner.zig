const std = @import("std");
const AtomicBool = std.atomic.Atomic(bool);
const Mutex = Thread.Mutex;
const Thread = std.Thread;
const time = std.time;
const Spinner = @This();

const default_framerate = 100 * time.ns_per_ms;
const default_charset = [_][]const u8{ "|", "/", "-", "\\" };

keep_going: AtomicBool,
spinner_thread: ?Thread,

// The number of nanoseconds to wait between frames.
framerate_ns: u64,

charset: []const []const u8,
message: []const u8,

pub fn new(framerate_ns: ?u64, charset: ?[]const []const u8, message: ?[]const u8) Spinner {
    return Spinner{
        .keep_going = AtomicBool.init(false),
        .spinner_thread = null,
        .framerate_ns = framerate_ns orelse default_framerate,
        .charset = charset orelse &default_charset,
        .message = message orelse "",
    };
}

pub fn start(sp: *Spinner) !void {
    sp.keep_going.store(true, .SeqCst);
    sp.spinner_thread = try Thread.spawn(.{}, writer, .{sp});
}

pub fn stop(sp: *Spinner) void {
    sp.keep_going.store(false, .SeqCst);
    if (sp.spinner_thread) |*thread| thread.join();
}

fn animateSpinnerOnce(sp: *Spinner) !void {
    var stdOut = std.io.getStdOut();

    for (sp.charset) |frame| {
        _ = try stdOut.write("\r");

        _ = try stdOut.write(frame);
        _ = try stdOut.write(" ");
        _ = try stdOut.write(sp.message);

        time.sleep(sp.framerate_ns);
    }
}

fn writer(sp: *Spinner) !void {
    while (true) {
        if (!sp.keep_going.load(.SeqCst)) break;

        try sp.animateSpinnerOnce();
    }
}
