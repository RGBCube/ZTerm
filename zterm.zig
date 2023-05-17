const Spinner = @import("src/Spinner.zig");


const time = @import("std").time;

pub fn main() !void {
    var sp = Spinner.new(null, null, "Loading...");
    try sp.start();
    time.sleep(5 * time.ns_per_s);
    sp.stop();
}
