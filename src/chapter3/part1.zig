const std = @import("std");
const Allocator = std.mem.Allocator;

fn solve(m: usize, n: usize, t: usize) isize {
    if (t == 0)
        return 0;

    var first: isize = -1;

    if (m <= t)
        first = solve(m, n, t - m);

    var second: isize = -1;

    if (n <= t)
        second = solve(m, n, t - n);

    if (first == -1 and second == -1)
        return -1;

    return 1 + @max(first, second);
}

pub fn main() !void {
    const str_tree = "4 9 23";
    var result: isize = -1;
    var i: u32 = 0;

    var tokens = std.mem.tokenizeAny(u8, str_tree, " ");

    const m: usize = std.fmt.parseInt(usize, tokens.next().?, 10) catch 0;
    const n: usize = std.fmt.parseInt(usize, tokens.next().?, 10) catch 0;
    const t: usize = std.fmt.parseInt(usize, tokens.next().?, 10) catch 0;

    while (result == -1) {
        result = solve(m, n, t - i);
        i += 1;
    }

    std.debug.print("part 1: {d}\n", .{result});
}
