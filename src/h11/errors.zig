const i_headers = @import("http/headers.zig");

pub const ParsingError = error{
    Incomplete,
    Invalid,
    OutOfMemory,
    TooManyHeaders,
} || i_headers.AllocationError;
