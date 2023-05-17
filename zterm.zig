const Spinner = @import("src/Spinner.zig");


const std = @import("std");
const time = std.time;

pub fn main() !void {
    var sp = Spinner.new(100 * time.ns_per_ms, null, "Loading...");
    try sp.start();

    time.sleep(5 * time.ns_per_s);
    
    sp.stop();
}
