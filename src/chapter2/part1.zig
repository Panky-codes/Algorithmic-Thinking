const std = @import("std");
const Allocator = std.mem.Allocator;

const Node = struct {
    left: ?*Node = null,
    right: ?*Node = null,
    candy: i32 = 0,
};

const Parser = struct {
    input: []const u8,
    pos: usize = 0,
    allocator: Allocator,

    pub fn init(input: []const u8, allocator: Allocator) Parser {
        return .{
            .input = input,
            .allocator = allocator,
        };
    }

    pub fn parse(self: *Parser) !*Node {
        const node = try self.allocator.create(Node);
        node.* = .{}; // Initialize with defaults

        if (self.pos >= self.input.len) return error.UnexpectedEndOfInput;

        if (self.input[self.pos] == '(') {
            self.pos += 1; // skip '('

            node.left = try self.parse();

            // Skip delimiter (space)
            if (self.pos < self.input.len and self.input[self.pos] == ' ') {
                self.pos += 1;
            }

            node.right = try self.parse();

            // Skip closing parenthesis
            if (self.pos < self.input.len and self.input[self.pos] == ')') {
                self.pos += 1;
            }

            return node;
        }

        // Parse number (Leaf)
        const start = self.pos;
        while (self.pos < self.input.len) : (self.pos += 1) {
            const c = self.input[self.pos];
            if (c == ' ' or c == ')') break;
        }

        if (start == self.pos) return error.InvalidFormat;

        const num_slice = self.input[start..self.pos];
        node.candy = try std.fmt.parseInt(i32, num_slice, 10);

        return node;
    }
};

fn total_candy(node_opt: ?*const Node) i32 {
    const node = node_opt orelse return 0;

    if (node.left == null and node.right == null) {
        return node.candy;
    }

    return total_candy(node.left) + total_candy(node.right);
}

fn tree_streets(node_opt: ?*const Node) i32 {
    const node = node_opt orelse return 0;

    if (node.left == null and node.right == null) {
        return 0;
    }

    return tree_streets(node.left) + tree_streets(node.right) + 4;
}

fn tree_height(node_opt: ?*const Node) i32 {
    const node = node_opt orelse return 0;

    if (node.left == null and node.right == null) {
        return 0;
    }

    return 1 + @max(tree_height(node.left), tree_height(node.right));
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const str_tree = "((4 9) 15)";

    var parser = Parser.init(str_tree, allocator);
    const root = try parser.parse();

    std.debug.print("part 1: {d} part2: {d}\n", .{ total_candy(root), tree_streets(root) - tree_height(root) });
}
