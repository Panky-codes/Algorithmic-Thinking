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

    pub fn parse(self: *Parser) !*Node {
        const node = try self.allocator.create(Node);
        node.* = .{}; // Initialize with defaults
        var it_line = std.mem.splitAny(u8, self.input, "\n");
        while (it_line.next()) | line | {
                var it_words = std.mem.splitAny(u8, line, " ");
                var pos: u32 = 0;
                while (it_words.next()) | name | {
                    if (pos == 0) {
                        try self.hashNames.put(name, node);
                        node.name = name;
                        pos += 1;
                        continue;
                    }
                    if (pos == 1) {
                        node.num_child = std.fmt.parseInt(u32, name, 10) catch 0;
                        pos += 1;
                        std.debug.print("num child: {d}\n", .{node.num_child});
                        continue;
                    }

                    const child_node = try self.allocator.create(Node);
                    child_node.* = .{};
                }
            }

        return node;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const str_tree =
    \\Zara 1 Amber
    \\Amber 4 Vlad Sana Mira Lola
    ;
    
    var parser = Parser.init(str_tree, allocator);
    const root = try parser.parse();

    _ = root;

    // std.debug.print("part 1: {d} part2: {d}\n", .{total_candy(root), tree_streets(root) - tree_height(root)});
}
