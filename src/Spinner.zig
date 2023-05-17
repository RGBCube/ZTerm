const Spinner = @This();

const std = @import("std");
const Mutex = std.Thread.Mutex;
const time = std.time;

const default_frame_rate = 150 * time.ns_per_ms;
const default_charset = [_][]const u8{ "|", "/", "-", "\\" };

// When locked, the spinner will stop spinning.
stop_lock: Mutex,
// Used to check if stopped.
stopped_lock: Mutex,

// The number of nanoseconds to wait between frames.
framerate: u64,

charset: [][]const u8,
message: []const u8,

pub fn new(framerate: ?u64, charset: ?[][]const u8, message: ?[]const u8) Spinner {
    return Spinner{
        .stop_lock = Mutex{},
        .stopped_lock = Mutex{},
        .framerate = framerate orelse default_frame_rate,
        .charset = charset orelse default_charset,
        .message = message orelse "",
    };
}

pub fn start(sp: *Spinner) void {
    sp.stop_lock.unlock();
    sp.stopped_lock.unlock();
    async sp.writer();
}

pub fn stop(sp: *Spinner) void {
    sp.stop_lock.lock();
    sp.stopped_lock.lock();
}

fn animateSpinnerOnce(sp: *Spinner) void {
    var stdOut = std.io.getStdOut();

    for (sp.charset) |frame| {
        stdOut.write(frame);
        stdOut.write(" ");
        stdOut.write(sp.message);

        // Jumps to the start of the line.
        stdOut.write("\r");
        stdOut.flush();

        time.sleep(sp.framerate);
    }
}

fn writer(sp: *Spinner) void {
    while (true) {
        // Stops if it has been locked by .stop().
        if (sp.stop_lock.tryLock()) {
            break;
        }
        sp.stop_lock.unlock();

        sp.animateSpinnerOnce();
    }
    sp.stopped_lock.lock();
}

test "asd" {
    var sp = Spinner.new(null, null, "Loading...");
    sp.start();
    time.sleep(5 * time.ns_per_s);
    sp.stop();
}
