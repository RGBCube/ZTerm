const std = @import("std");
const time = std.time;
const zterm = struct {
    const Spinner = @import("src/Spinner.zig");
};

pub fn main() !void {
    var sp = zterm.Spinner{
        .loading_charset = &[_][]const u8{"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"},
        .loading_message = "Selling all your data to the CCP...",
        .finished_charset = "✓",
        .finished_message = "Lock your doors.",
    };
    try sp.start();

    time.sleep(3 * time.ns_per_s);
    var stdOut = std.io.getStdOut();
    try stdOut.writeAll("\rCalculating very important stuff while selling your data...\n");
    time.sleep(2 * time.ns_per_s);

    try sp.stop();
}
