const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Node = struct {
    num_child: u32 = 0,
    name: ?[]const u8 = null,
    score: u32 = 0,
    children: ?[]*Node = null,
};

const Parser = struct {
    input: []const u8,
    pos: usize = 0,
    allocator: Allocator,
    hashNames: std.StringHashMap(*Node),
    keys: ArrayList(*Node),

    pub fn init(input: []const u8, allocator: Allocator) Parser {
        return .{ .input = input, .allocator = allocator, .hashNames = std.StringHashMap(*Node).init(allocator), .keys = .empty };
    }

    fn get_or_alloc(self: *Parser, name: []const u8) !*Node {
        var node: ?*Node = self.hashNames.get(name);

        if (node != null)
            return node.?;

        node = try self.allocator.create(Node);
        node.?.* = .{}; // Initialize with defaults
        node.?.name = name;
        try self.hashNames.put(name, node.?);
        try self.keys.append(self.allocator, node.?);

        return node.?;
    }

    pub fn parse(self: *Parser) !void {
        var it_line = std.mem.splitAny(u8, self.input, "\n");

        while (it_line.next()) |line| {
            var it_words = std.mem.splitAny(u8, line, " ");
            var pos: u32 = 0;
            var parent_node: *Node = undefined;

            while (it_words.next()) |name| : (pos += 1) {
                if (pos == 0) {
                    parent_node = try self.get_or_alloc(name);
                    continue;
                }
                if (pos == 1) {
                    const num_child = std.fmt.parseInt(u32, name, 10) catch 0;

                    parent_node.num_child = num_child;
                    parent_node.children = try self.allocator.alloc(*Node, num_child);
                    continue;
                }

                const child_node: *Node = try self.get_or_alloc(name);
                parent_node.children.?[pos - 2] = child_node;
            }
        }
    }

    fn score_one(node: *Node, d: u32) u32 {
        if (d == 1)
            return node.num_child;

        var total: u32 = 0;
        var n: u32 = 0;

        while (n < node.num_child) : (n += 1) {
            total = total + score_one(node.children.?[n], d - 1);
        }
        return total;
    }

    pub fn score_all(self: *Parser, d: u32) void {
        var it = self.hashNames.iterator();

        while (it.next()) |entry| {
            const node: *Node = entry.value_ptr.*;
            node.score = score_one(node, d);
        }
    }
};

pub fn cmp() fn (void, *Node, *Node) bool {
    return struct {
        // TODO: if the value are equal, do a strcmp
        pub fn inner(_: void, a: *Node, b: *Node) bool {
            return a.score > b.score;
        }
    }.inner;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const str_tree =
        \\Lucas 1 Enzo
        \\Zara 1 Amber
        \\Sana 2 Gabriel Lucas
        \\Enzo 2 Min Becky
        \\Kevin 2 Jad Cassie
        \\Amber 4 Vlad Sana Ashley Kevin
        \\Vlad 1 Omar
    ;

    var parser = Parser.init(str_tree, allocator);
    try parser.parse();

    parser.score_all(2);

    std.mem.sort(*Node, parser.keys.items, {}, cmp());

    for (parser.keys.items) |key| {
        std.debug.print(" Name {s} score {d} \n", .{ key.name.?, key.score });
    }
}
