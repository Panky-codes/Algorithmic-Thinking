const std = @import("std");
const Allocator = std.mem.Allocator;

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

    pub fn init(input: []const u8, allocator: Allocator) Parser {
        return .{
            .input = input,
            .allocator = allocator,
            .hashNames = std.StringHashMap(*Node).init(allocator),
        };
    }

    fn get_or_alloc(self: *Parser, name: []const u8) !*Node {
        var node: ?*Node = self.hashNames.get(name);

        if (node != null)
            return node.?;

        node = try self.allocator.create(Node);
        node.?.* = .{}; // Initialize with defaults
        node.?.name = name;
        try self.hashNames.put(name, node.?);

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
                // std.debug.print("Parser name: {s} {d} {any}\n", .{name, pos, child_node});
            }
        }
    }
};

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
        \\Amber 4 Vlad Sana Mira Lola
        \\Vlas 1 Omar
    ;

    var parser = Parser.init(str_tree, allocator);
    const root = try parser.parse();
    var it = parser.hashNames.iterator();

    while (it.next()) |entry| {
        const node: *Node = entry.value_ptr.*;
        var pos: u32 = 0;

        if (node.num_child == 0)
            continue;
        std.debug.print("Parent name: {s}\n", .{node.name.?});

        while (pos < node.num_child) {
            std.debug.print("   - Child name: {s} \n", .{node.children.?[pos].name.?});
            pos += 1;
        }
    }
    _ = root;

    // std.debug.print("part 1: {d} part2: {d}\n", .{total_candy(root), tree_streets(root) - tree_height(root)});
}
