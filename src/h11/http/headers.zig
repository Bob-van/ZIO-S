const i_std = @import("std");
const i_header = @import("header.zig");
const i_name = @import("name.zig");
const i_value = @import("value.zig");

pub const AllocationError = error{OutOfMemory};

pub const Headers = struct {
    allocator: *const i_std.mem.Allocator,
    _items: i_std.ArrayList(i_header.Header),

    pub const Error = error{ InvalidHeaderName, InvalidHeaderValue } || AllocationError;

    pub fn init(allocator: *const i_std.mem.Allocator) Headers {
        return Headers{ .allocator = allocator, ._items = i_std.ArrayList(i_header.Header).init(allocator.*) };
    }

    pub fn deinit(self: *Headers) void {
        self._items.deinit();
    }

    pub fn append(self: *Headers, name: []const u8, value: []const u8) Error!void {
        try self._items.append(i_header.Header{
            .name = i_name.HeaderName.parse(name) catch return error.InvalidHeaderName,
            .value = i_value.HeaderValue.parse(value) catch return error.InvalidHeaderValue,
        });
    }

    pub inline fn len(self: Headers) usize {
        return self._items.items.len;
    }

    pub inline fn items(self: Headers) []i_header.Header {
        return self._items.items;
    }

    pub fn get(self: Headers, name: []const u8) ?i_header.Header {
        const _type = i_name.HeaderName.type_of(name);
        return switch (_type) {
            .Custom => self.get_custom_header(name),
            else => self.get_standard_header(_type),
        };
    }

    pub fn list(self: Headers, name: []const u8) AllocationError![]i_header.Header {
        const _type = i_name.HeaderName.type_of(name);
        return switch (_type) {
            .Custom => self.get_custom_header_list(name),
            else => self.get_standard_header_list(_type),
        };
    }

    inline fn get_custom_header_list(self: Headers, name: []const u8) AllocationError![]i_header.Header {
        var result = i_std.ArrayList(i_header.Header).init(self.allocator);
        for (self.items()) |header| {
            if (header.name.type == .Custom and i_std.mem.eql(u8, header.name.raw(), name)) {
                try result.append(header);
            }
        }
        return result.toOwnedSlice();
    }

    inline fn get_standard_header_list(self: Headers, name: i_name.HeaderType) AllocationError![]i_header.Header {
        var result = i_std.ArrayList(i_header.Header).init(self.allocator);
        for (self.items()) |header| {
            if (header.name.type == name) {
                try result.append(header);
            }
        }
        return result.toOwnedSlice();
    }

    inline fn get_custom_header(self: Headers, name: []const u8) ?i_name.Header {
        for (self.items()) |header| {
            if (header.name.type == .Custom and i_std.mem.eql(u8, header.name.raw(), name)) {
                return header;
            }
        }
        return null;
    }

    inline fn get_standard_header(self: Headers, name: i_name.HeaderType) ?i_header.Header {
        for (self.items()) |header| {
            if (header.name.type == name) {
                return header;
            }
        }
        return null;
    }
};
