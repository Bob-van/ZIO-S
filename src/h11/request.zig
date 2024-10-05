const i_std = @import("std");
const i_headers = @import("http/headers.zig");
const i_methods = @import("http/methods.zig");
const i_version = @import("http/version.zig");
const i_errors = @import("errors.zig");
const i_utils = @import("utils.zig");

pub const Request = struct {
    method: i_methods.Method,
    target: []const u8,
    version: i_version.Version,
    headers: i_headers.Headers,

    pub const Error = error{
        MissingHost,
        TooManyHost,
    };

    pub fn init(method: i_methods.Method, target: []const u8, version: i_version.Version, headers: i_headers.Headers) Error!Request {
        // A single 'Host' header is mandatory for HTTP/1.1
        // Cf: https://tools.ietf.org/html/rfc7230#section-5.4
        var hostCount: u32 = 0;
        for (headers.items()) |header| {
            if (header.name.type == .Host) {
                hostCount += 1;
            }
        }
        if (hostCount == 0 and version == .Http11) {
            return error.MissingHost;
        }
        if (hostCount > 1) {
            return error.TooManyHost;
        }
        return Request{
            .method = method,
            .target = target,
            .version = version,
            .headers = headers,
        };
    }

    pub fn default(allocator: *const i_std.mem.Allocator) Request {
        return Request{
            .method = .Get,
            .target = "/",
            .version = .Http11,
            .headers = i_headers.Headers.init(allocator),
        };
    }

    pub fn deinit(self: *Request) void {
        self.headers.deinit();
    }

    pub fn parse(allocator: *const i_std.mem.Allocator, buffer: []const u8) !Request {
        const line_end = i_std.mem.indexOfPosLinear(u8, buffer, 0, "\r\n") orelse return error.Incomplete;
        var requestLine = buffer[0..line_end];
        var cursor: usize = 0;
        const method = for (requestLine, 0..) |char, i| {
            if (char == ' ') {
                cursor += i + 1;
                const value = try i_methods.Method.from_bytes(requestLine[0..i]);
                break value;
            }
        } else {
            return error.Invalid;
        };
        const target = try i_utils.readUri(requestLine[cursor..]);
        cursor += target.len + 1;

        const version = i_version.Version.from_bytes(requestLine[cursor..]) orelse return error.Invalid;
        if (version != .Http11) {
            return error.Invalid;
        }
        const _headers = try i_utils.parseHeaders(allocator, buffer[requestLine.len + 2 ..], 128);
        return Request{
            .headers = _headers,
            .version = version,
            .method = method,
            .target = target,
        };
    }

    pub fn serialize(self: Request, allocator: *const i_std.mem.Allocator) ![]const u8 {
        var buffer = i_std.mem.std.ArrayList(u8).init(allocator);

        // Serialize the request line
        try buffer.appendSlice(self.method.to_bytes());
        try buffer.append(' ');
        try buffer.appendSlice(self.target);
        try buffer.append(' ');
        try buffer.appendSlice(self.version.to_bytes());
        try buffer.appendSlice("\r\n");

        // Serialize the headers
        for (self.headers.items()) |header| {
            try buffer.appendSlice(header.name.raw());
            try buffer.appendSlice(": ");
            try buffer.appendSlice(header.value);
            try buffer.appendSlice("\r\n");
        }
        try buffer.appendSlice("\r\n");

        return buffer.toOwnedSlice();
    }
};
