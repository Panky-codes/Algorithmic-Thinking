# Algorithmic Thinking in Zig

This project is set up to solve problems from "Algorithmic Thinking" using Zig.

## Environment

This project uses `nix` to manage dependencies. To enter the development environment:

```bash
nix-shell
```

## Running a Solution

The `build.zig` is configured to run individual source files.

To run a specific problem file:

```bash
zig build run -Dproblem=src/chapter1/hello.zig
```

## Structure

Place your solutions in the `src` directory, organized by chapter or problem name.
Each file should be a valid Zig executable (contain a `pub fn main() !void`).
