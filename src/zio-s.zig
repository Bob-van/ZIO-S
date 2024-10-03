const std = @import("std");
const thpool = @import("ThreadPool.zig");

pub const TaskData = struct {
    connection: std.net.Server.Connection,
    allocator: *const std.mem.Allocator,
};

const MessageNode = struct {
    next: ?*MessageNode = null,
    message: []u8,
};

const LinkedMessage = struct {
    head: ?*MessageNode,
    tail: ?*MessageNode,

    fn init() LinkedMessage {
        return .{ .head = null, .tail = null };
    }

    fn deinit(self: *LinkedMessage, allocator: *const std.mem.Allocator) void {
        var current = self.head;
        while (current) |node| {
            current = node.next;
            allocator.free(node.message);
            allocator.destroy(node);
        }
    }

    fn insert(self: *LinkedMessage, message: []u8, allocator: *const std.mem.Allocator) !void {
        if (self.tail) |back| {
            back.next = try allocator.create(MessageNode);
            back.next.?.message = message;
            self.tail = back.next;
        } else {
            self.head = try allocator.create(MessageNode);
            self.head.?.message = message;
            self.tail = self.head;
        }
    }

    fn print(self: *const LinkedMessage) void {
        var current = self.head;
        while (current) |node| {
            std.debug.print("=>\t{s}\n", .{node.message});
            current = node.next;
        }
    }
};

fn readLine(reader: std.net.Stream.Reader, allocator: *const std.mem.Allocator) ![]u8 {
    return (try reader.readUntilDelimiterOrEofAlloc(allocator.*, '\n', 65536)).?;
}

fn validationParsing(task: *thpool.Task, data: TaskData) void {
    std.debug.print("client got to parsing\n", .{});
    const allocator = data.allocator;
    defer allocator.destroy(task);

    const client = data.connection;
    defer client.stream.close();
    const client_reader = client.stream.reader();
    //const client_writer = client.stream.writer();
    var lm = LinkedMessage.init();
    defer lm.deinit(allocator);

    while (true) {
        const message = readLine(client_reader, allocator) catch return;
        if (message.len == 1) {
            allocator.free(message);
            break;
        }
        lm.insert(message, allocator) catch return;
    }

    lm.print();
    std.debug.print("\n", .{});
}

pub const Http = struct {
    server: std.net.Server,
    pool: thpool,

    pub fn init(address: std.net.Address, max_threads: u32) !Http {
        const tmp = try address.listen(.{});
        return .{ .server = tmp, .pool = thpool.init(.{ .max_threads = max_threads }) };
    }

    pub fn deinit(self: *Http) void {
        self.server.deinit();
        self.pool.shutdown();
        self.pool.deinit();
    }

    pub fn run(self: *Http, allocator: *const std.mem.Allocator) !void {
        std.debug.print("server is accpeting\n", .{});
        while (true) {
            const connection = try self.server.accept();
            std.debug.print("server accepted a client\n", .{});
            const task = try allocator.create(thpool.Task);
            task.callback = validationParsing;
            task.data = .{ .connection = connection, .allocator = allocator };
            self.pool.schedule(thpool.Batch.from(task));
        }
    }
};
