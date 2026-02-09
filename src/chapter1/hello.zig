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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const str_tree = "(((4 9) 15) 20)";
    
    var parser = Parser.init(str_tree, allocator);
    const root = try parser.parse();

    const result = total_candy(root);
    std.debug.print("{d}\n", .{result});
}