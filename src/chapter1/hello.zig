const std = @import("std");
const Allocator = std.mem.Allocator;

const Node = struct {
    left: ?*Node,
    right: ?*Node,
    candy: i32
};

fn read_tree_helper(l: []const u8,  pos: *u32, allocator: Allocator) ?*Node 
{
    const alloc_node = allocator.create(Node) catch null;
    var node = alloc_node.?;

    if (l[pos.*] == '(') {
        pos.* += 1;
        node.left = read_tree_helper(l, pos, allocator);

        pos.* += 1;
        node.right = read_tree_helper(l, pos, allocator);

        pos.* += 1;

        return node;
    }

    node.left = null;
    node.right = null;


    const start = pos.*;

    while (pos.* < l.len and l[pos.*] != ' ' and l[pos.*] != ')')
        : (pos.*+= 1) {}

    node.candy = std.fmt.parseInt(i32, l[start..(pos.*)], 10) catch 0;

    return node;
}

fn walk_tree(n: ?*Node) void {
    if ((n.?.left == null) and (n.?.right == null)) {
        std.debug.print("{d} ", .{n.?.candy});
        return;
    }

    if (n.?.left) |node|
        walk_tree(node);

    if (n.?.right) |node|
        walk_tree(node);
}

fn total_candy(n: ?*Node) i32 {

    if ((n.?.left == null) and (n.?.right == null))
        return n.?.candy;

    return total_candy(n.?.left) + total_candy(n.?.right);

}

pub fn main() !void {
    const str_tree = "(((4 9) 15) 20)";
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var pos: u32 = 0;

    const root = read_tree_helper(str_tree, &pos, allocator);

    // walk_tree(root);

    std.debug.print("{d}", .{total_candy(root)});

}
