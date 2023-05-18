const std = @import("std");
const time = std.time;
const zterm = struct {
    const Spinner = @import("src/Spinner.zig");
};

pub fn main() !void {
    var sp = zterm.Spinner{
        .charset = zterm.Spinner.charsets[3],
        .message = "Selling all your data to the CCP...",
    };
    try sp.start();

    time.sleep(3 * time.ns_per_s);
    sp.setMessage("Calculating very important stuff while selling your data...");

    time.sleep(2 * time.ns_per_s);
    try sp.stop(.{
        .charset = "✓",
        .message = "Successfully sold all your data to the CCP! You data is not in safe hands!",
    });
}
