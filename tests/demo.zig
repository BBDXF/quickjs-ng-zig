const std = @import("std");
const c = @cImport({
    @cInclude("wrapper.h");
});

pub fn main() !void {
    if (std.os.argv.len < 2) {
        std.debug.print("usage: demo js_path\n", .{});
        return;
    }
    const app = c.js_app_new(-1, -1);
    _ = c.js_app_eval_file(app, std.os.argv[1]);
    c.js_app_run_loop(app);
    c.js_app_free(app);
}
