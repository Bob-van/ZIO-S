const i_name = @import("name.zig");
const i_value = @import("value.zig");

pub const Header = struct {
    name: i_name.HeaderName,
    value: []const u8,

    pub fn as_slice(comptime headers: anytype) []Header {
        const typeof = @TypeOf(headers);
        const typeinfo = @typeInfo(typeof);
        switch (typeinfo) {
            .Struct => |obj| {
                comptime {
                    var result: [obj.fields.len]Header = undefined;
                    var i = 0;
                    while (i < obj.fields.len) {
                        _ = i_name.HeaderName.parse(headers[i][0]) catch {
                            @compileError("Invalid header name: " ++ headers[i][0]);
                        };

                        _ = i_value.HeaderValue.parse(headers[i][1]) catch {
                            @compileError("Invalid header value: " ++ headers[i][1]);
                        };

                        const t = i_name.HeaderType.from_bytes(headers[i][0]);
                        const n = headers[i][0];
                        const v = headers[i][1];
                        result[i] = Header{ .name = .{ .type = t, .value = n }, .value = v };
                        i += 1;
                    }
                    return &result;
                }
            },
            else => {
                @compileError("The parameter type must be an anonymous list literal.\n" ++ "Ex: Header.as_slice(.{.{\"Gotta-Go\", \"Fast!\"}});");
            },
        }
    }
};
