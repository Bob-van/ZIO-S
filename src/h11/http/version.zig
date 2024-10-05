const std = @import("std");

pub const Version = enum {
    Http09,
    Http10,
    Http11,
    Http2,
    Http3,

    pub fn to_bytes(self: Version) []const u8 {
        return switch (self) {
            .Http09 => "HTTP/0.9",
            .Http10 => "HTTP/1.0",
            .Http11 => "HTTP/1.1",
            .Http2 => "HTTP/2",
            .Http3 => "HTTP/3",
        };
    }

    pub fn from_bytes(value: []const u8) ?Version {
        const isInvalid = (value.len < 6 or value.len > 8 or !std.mem.eql(u8, value[0..5], "HTTP/"));
        if (isInvalid) {
            return null;
        }

        if (std.mem.eql(u8, value[5..], "0.9")) {
            return .Http09;
        } else if (std.mem.eql(u8, value[5..], "1.0")) {
            return .Http10;
        } else if (std.mem.eql(u8, value[5..], "1.1")) {
            return .Http11;
        } else if (std.mem.eql(u8, value[5..], "2")) {
            return .Http2;
        } else if (std.mem.eql(u8, value[5..], "3")) {
            return .Http3;
        }

        return null;
    }
};
