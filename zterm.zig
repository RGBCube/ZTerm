const Spinner = @import("src/Spinner.zig");


const std = @import("std");
const time = std.time;

pub fn main() !void {
    var sp = Spinner{
        .loading_message = "Loading",
        .finished_message = "Done",
    };
    try sp.start();

    time.sleep(3 * time.ns_per_s);
    
    try sp.stop();
}
