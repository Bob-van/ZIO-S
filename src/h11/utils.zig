const i_std = @import("std");
const i_errors = @import("errors.zig");
const i_headers = @import("http/headers.zig");

// ASCII codes accepted for an URI
// Cf: Borrowed from Seamonstar's httparse library.
// https://github.com/seanmonstar/httparse/blob/01e68542605d8a24a707536561c27a336d4090dc/src/lib.rs#L63
const URI_MAP = [_]bool{
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    //   \0                                                             \t     \n                   \r
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    //   commands
    false, true,  false, true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,
    //   \s     !     "      #     $     %     &     '     (     )     *     +     ,     -     .     /
    true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  false, true,  false, true,
    //   0     1     2     3     4     5     6     7     8     9     :     ;     <      =     >      ?
    true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,
    //   @     A     B     C     D     E     F     G     H     I     J     K     L     M     N     O
    true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,
    //   P     Q     R     S     T     U     V     W     X     Y     Z     [     \     ]     ^     _
    true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,
    //   `     a     b     c     d     e     f     g     h     i     j     k     l     m     n     o
    true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  false,
    //   p     q     r     s     t     u     v     w     x     y     z     {     |     }     ~     del
    //   ====== Extended ASCII (aka. obs-text) ======
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
};

fn is_uri_token(char: u8) bool {
    return URI_MAP[char];
}

pub fn readUri(buffer: []const u8) i_errors.ParsingError![]const u8 {
    for (buffer, 0..) |char, i| {
        if (char == ' ') {
            return buffer[0..i];
        }
        if (!is_uri_token(char)) {
            return error.Invalid;
        }
    }
    return error.Invalid;
}

const HeaderParseError = error{
    WrongEndingBytes,
    TooManyHeaders,
    NameEndIsNull,
    ValueEndIsNull,
};

pub fn parseHeaders(allocator: *const i_std.mem.Allocator, buffer: []const u8, max_headers: usize) !i_headers.Headers {
    var remaining_bytes = buffer[0..];
    var headers = i_headers.Headers.init(allocator);
    errdefer headers.deinit();
    while (true) {
        if (remaining_bytes.len == 0) {
            break;
        }
        if (remaining_bytes.len < 2) {
            return HeaderParseError.WrongEndingBytes;
        }

        if (remaining_bytes[0] == '\r' and remaining_bytes[1] == '\n') {
            break;
        }

        if (headers.len() >= max_headers) {
            return HeaderParseError.TooManyHeaders;
        }

        const name_end = i_std.mem.indexOfScalar(u8, remaining_bytes, ':') orelse return HeaderParseError.NameEndIsNull;
        const name = remaining_bytes[0..name_end];
        remaining_bytes = remaining_bytes[name_end + 1 ..];

        const value_end = i_std.mem.indexOf(u8, remaining_bytes, "\r\n") orelse return HeaderParseError.ValueEndIsNull;
        var value = remaining_bytes[0..value_end];
        if (i_std.ascii.isWhitespace(value[0])) {
            value = value[1..];
        }

        try headers.append(name, value);
        remaining_bytes = remaining_bytes[value_end + 2 ..];
    }
    return headers;
}
