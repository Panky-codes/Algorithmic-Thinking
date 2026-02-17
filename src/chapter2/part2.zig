const std = @import("std");
const Allocator = std.mem.Allocator;

const Node = struct {
    name: []const u8,
    score: u32 = 0,
    children: []const *Node = &[_]*Node{},
};

const Parser = struct {
    allocator: Allocator,
    nodes: std.StringHashMap(*Node),

    pub fn init(allocator: Allocator) Parser {
        return .{
            .allocator = allocator,
            .nodes = std.StringHashMap(*Node).init(allocator),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.nodes.deinit();
    }

    fn getNode(self: *Parser, name: []const u8) !*Node {
        const result = try self.nodes.getOrPut(name);
        if (result.found_existing) {
            return result.value_ptr.*;
        }

        const node = try self.allocator.create(Node);
        node.* = .{ .name = name };
        result.value_ptr.* = node;
        return node;
    }

    pub fn parse(self: *Parser, input: []const u8) !void {
        var lines = std.mem.tokenizeAny(u8, input, "\n\r");
        while (lines.next()) |line| {
            var tokens = std.mem.tokenizeAny(u8, line, " ");

            const parent_name = tokens.next() orelse continue;
            const parent = try self.getNode(parent_name);

            const count_str = tokens.next() orelse continue;
            const count = std.fmt.parseInt(usize, count_str, 10) catch 0;

            if (count > 0) {
                const children = try self.allocator.alloc(*Node, count);
                parent.children = children;

                var i: usize = 0;
                while (i < count) : (i += 1) {
                    if (tokens.next()) |child_name|
                        children[i] = try self.getNode(child_name);
                }
            }
        }
    }

    fn scoreOne(node: *Node, d: u32) u32 {
        if (d == 1) return @intCast(node.children.len);

        var total: u32 = 0;
        for (node.children) |child| {
            total += scoreOne(child, d - 1);
        }
        return total;
    }

    pub fn scoreAll(self: *Parser, d: u32) void {
        var it = self.nodes.valueIterator();
        while (it.next()) |node_ptr| {
            node_ptr.*.score = scoreOne(node_ptr.*, d);
        }
    }
};

fn compareNodes(_: void, a: *Node, b: *Node) bool {
    if (a.score != b.score) {
        return a.score > b.score;
    }
    return std.mem.order(u8, a.name, b.name) == .lt;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const str_tree =
        "Lucas 1 Enzo\n" ++
        "Zara 1 Amber\n" ++
        "Sana 2 Gabriel Lucas\n" ++
        "Enzo 2 Min Becky\n" ++
        "Kevin 2 Jad Cassie\n" ++
        "Amber 4 Vlad Sana Ashley Kevin\n" ++
        "Vlad 1 Omar";

    var parser = Parser.init(allocator);
    defer parser.deinit();

    try parser.parse(str_tree);
    parser.scoreAll(2);

    var sorted_nodes = std.ArrayList(*Node){};
    defer sorted_nodes.deinit(allocator);

    var it = parser.nodes.valueIterator();
    while (it.next()) |n| {
        try sorted_nodes.append(allocator, n.*);
    }

    std.mem.sort(*Node, sorted_nodes.items, {}, compareNodes);

    for (sorted_nodes.items) |node| {
        std.debug.print(" Name {s} score {d} \n", .{ node.name, node.score });
    }
}
