const i_std = @import("std");
const i_thpool = @import("threadpool.zig");
const i_parser = @import("h11/request.zig");

pub const TaskData = struct {
    connection: i_std.net.Server.Connection,
    allocator: *const i_std.mem.Allocator,
};

const MessageNode = struct {
    next: ?*MessageNode = null,
    message: []u8,
};

const LinkedMessage = struct {
    head: ?*MessageNode,
    tail: ?*MessageNode,
    len: usize = 0,
    count: usize = 0,

    fn init() LinkedMessage {
        return .{ .head = null, .tail = null };
    }

    fn deinit(self: *LinkedMessage, allocator: *const i_std.mem.Allocator) void {
        var current = self.head;
        while (current) |node| {
            current = node.next;
            allocator.free(node.message);
            allocator.destroy(node);
        }
    }

    fn insert(self: *LinkedMessage, message: []u8, allocator: *const i_std.mem.Allocator) !void {
        if (self.tail) |back| {
            back.next = try allocator.create(MessageNode);
            back.next.?.message = message;
            self.tail = back.next;
        } else {
            self.head = try allocator.create(MessageNode);
            self.head.?.message = message;
            self.tail = self.head;
        }
        self.len += message.len;
        self.count += 1;
    }

    fn print(self: *const LinkedMessage) void {
        var current = self.head;
        while (current) |node| {
            i_std.debug.print("=>\t{s}\n", .{node.message});
            current = node.next;
        }
    }

    fn combine(self: *const LinkedMessage, allocator: *const i_std.mem.Allocator) ![]u8 {
        const result = try allocator.alloc(u8, self.len + self.count);
        var index: usize = 0;
        var current = self.head;
        while (current) |node| {
            current = node.next;
            for (0..node.message.len) |i| {
                result[index + i] = node.message[i];
            }
            result[index + node.message.len] = '\n';
            index += node.message.len + 1;
        }
        return result;
    }
};

fn readLine(reader: i_std.net.Stream.Reader, allocator: *const i_std.mem.Allocator) ![]u8 {
    return (try reader.readUntilDelimiterOrEofAlloc(allocator.*, '\n', 65536)).?;
}

fn loadRequest(task: *i_thpool.Task) ![]u8 {
    i_std.debug.print("CLIENT\t=>\tREADING REQUEST\n", .{});
    const client_reader = task.data.connection.stream.reader();

    var lm = LinkedMessage.init();
    defer lm.deinit(task.data.allocator);

    while (true) {
        const message = try readLine(client_reader, task.data.allocator);
        if (message.len == 1) {
            task.data.allocator.free(message);
            break;
        }
        try lm.insert(message, task.data.allocator);
    }
    //lm.print();
    return try lm.combine(task.data.allocator);
}

fn validateAndParse(task: *i_thpool.Task, message: []u8) !i_parser.Request {
    i_std.debug.print("CLIENT\t=>\tPARSING REQUEST\n", .{});
    return try i_parser.Request.parse(task.data.allocator, message);
}

fn processClient(task: *i_thpool.Task) !void {
    // prepare deallocation of task
    const allocator = task.data.allocator;
    defer allocator.destroy(task);
    // prepare closure of the client stream
    const client = task.data.connection;
    defer client.stream.close();
    // try to read request from stream
    const message = try loadRequest(task);
    defer allocator.free(message);
    // try to parse the request for HTTP
    var result = try validateAndParse(task, message);
    defer result.deinit();
    //const client_writer = client.stream.writer();
    i_std.debug.print("CLIENT\t=>\tPARSING FINISHED\n", .{});
    i_std.debug.print("REQUEST\t=>\tTYPE: \"{s}\"\n", .{result.method.to_bytes()});
    i_std.debug.print("REQUEST\t=>\tVERSION: \"{s}\"\n", .{result.version.to_bytes()});
    i_std.debug.print("REQUEST\t=>\tTARGET: \"{s}\"\n", .{result.target});
    for (result.headers.items()) |header| {
        i_std.debug.print("REQUEST\t=>\tHEADER\t=>\tType: \"{s}\" Name: \"{s}\" Value: \"{s}\"\n", .{ @tagName(header.name.type), header.name.value, header.value });
    }
}

fn onRunCallback(task: *i_thpool.Task) void {
    processClient(task) catch |err| {
        i_std.debug.print("FATAL\t=>\t{}\t{s}\n", .{ err, @errorName(err) });
    };
}

pub const Http = struct {
    server: i_std.net.Server,
    pool: i_thpool,

    pub fn init(address: i_std.net.Address, max_threads: u32) !Http {
        const tmp = try address.listen(.{});
        return .{ .server = tmp, .pool = i_thpool.init(.{ .max_threads = max_threads }) };
    }

    pub fn deinit(self: *Http) void {
        self.server.deinit();
        self.pool.shutdown();
        self.pool.deinit();
    }

    pub fn run(self: *Http, allocator: *const i_std.mem.Allocator) !void {
        i_std.debug.print("SERVER\t=>\tIS LISTENING\n", .{});
        while (true) {
            const connection = try self.server.accept();
            i_std.debug.print("SERVER\t=>\tCLIENT ACCEPTED\n", .{});
            const task = try allocator.create(i_thpool.Task);
            task.callback = onRunCallback;
            task.data = .{ .connection = connection, .allocator = allocator };
            self.pool.schedule(i_thpool.Batch.from(task));
        }
    }
};
