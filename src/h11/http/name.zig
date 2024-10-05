pub const HeaderType = enum {
    Accept,
    AcceptCharset,
    AcceptEncoding,
    AcceptLanguage,
    AcceptRanges,
    AccessControlAllowCredentials,
    AccessControlAllowHeaders,
    AccessControlAllowMethods,
    AccessControlAllowOrigin,
    AccessControlExposeHeaders,
    AccessControlMaxAge,
    AccessControlRequestHeaders,
    AccessControlRequestMethod,
    Age,
    Allow,
    AltSvc,
    Authorization,
    CacheControl,
    Connection,
    ContentDisposition,
    ContentEncoding,
    ContentLanguage,
    ContentLength,
    ContentLocation,
    ContentRange,
    ContentSecurityPolicy,
    ContentSecurityPolicyReportOnly,
    ContentType,
    Cookie,
    Custom,
    Dnt,
    Date,
    Etag,
    Expect,
    Expires,
    Forwarded,
    From,
    Host,
    IfMatch,
    IfModifiedSince,
    IfNoneMatch,
    IfRange,
    IfUnmodifiedSince,
    LastModified,
    Link,
    Location,
    MaxForwards,
    Origin,
    Pragma,
    ProxyAuthenticate,
    ProxyAuthorization,
    PublicKeyPins,
    Range,
    Referer,
    ReferrerPolicy,
    Refresh,
    RetryAfter,
    SecWebSocketAccept,
    SecWebSocketExtensions,
    SecWebSocketKey,
    SecWebSocketProtocol,
    SecWebSocketVersion,
    Server,
    SetCookie,
    StrictTransportSecurity,
    Te,
    Trailer,
    TransferEncoding,
    UserAgent,
    Upgrade,
    UpgradeInsecureRequests,
    Vary,
    Via,
    Warning,
    WwwAuthenticate,
    XContentTypeOptions,
    XDnsPrefetchControl,
    XFrameOptions,
    XXssProtection,

    inline fn lowercased_equals(lowered: []const u8, value: []const u8) bool {
        if (lowered.len != value.len) {
            return false;
        }

        for (value, 0..) |char, i| {
            if (HEADER_NAME_MAP[char] != lowered[i]) {
                return false;
            }
        }
        return true;
    }

    pub fn from_bytes(value: []const u8) HeaderType {
        switch (value.len) {
            2 => {
                if (lowercased_equals("te", value)) {
                    return .Te;
                }
            },
            3 => {
                if (lowercased_equals("age", value)) {
                    return .Age;
                } else if (lowercased_equals("dnt", value)) {
                    return .Dnt;
                } else if (lowercased_equals("via", value)) {
                    return .Via;
                }
            },
            4 => {
                if (lowercased_equals("host", value)) {
                    return .Host;
                } else if (lowercased_equals("date", value)) {
                    return .Date;
                } else if (lowercased_equals("etag", value)) {
                    return .Etag;
                } else if (lowercased_equals("from", value)) {
                    return .From;
                } else if (lowercased_equals("link", value)) {
                    return .Link;
                } else if (lowercased_equals("vary", value)) {
                    return .Vary;
                }
            },
            5 => {
                if (lowercased_equals("allow", value)) {
                    return .Allow;
                } else if (lowercased_equals("range", value)) {
                    return .Range;
                }
            },
            6 => {
                if (lowercased_equals("accept", value)) {
                    return .Accept;
                } else if (lowercased_equals("cookie", value)) {
                    return .Cookie;
                } else if (lowercased_equals("expect", value)) {
                    return .Expect;
                } else if (lowercased_equals("origin", value)) {
                    return .Origin;
                } else if (lowercased_equals("pragma", value)) {
                    return .Pragma;
                } else if (lowercased_equals("server", value)) {
                    return .Server;
                }
            },
            7 => {
                if (lowercased_equals("alt-svc", value)) {
                    return .AltSvc;
                } else if (lowercased_equals("expires", value)) {
                    return .Expires;
                } else if (lowercased_equals("referer", value)) {
                    return .Referer;
                } else if (lowercased_equals("refresh", value)) {
                    return .Refresh;
                } else if (lowercased_equals("trailer", value)) {
                    return .Trailer;
                } else if (lowercased_equals("upgrade", value)) {
                    return .Upgrade;
                } else if (lowercased_equals("warning", value)) {
                    return .Warning;
                }
            },
            8 => {
                if (lowercased_equals("if-match", value)) {
                    return .IfMatch;
                } else if (lowercased_equals("if-range", value)) {
                    return .IfRange;
                } else if (lowercased_equals("location", value)) {
                    return .Location;
                }
            },
            9 => {
                if (lowercased_equals("forwarded", value)) {
                    return .Forwarded;
                }
            },
            10 => {
                if (lowercased_equals("connection", value)) {
                    return .Connection;
                } else if (lowercased_equals("set-cookie", value)) {
                    return .SetCookie;
                } else if (lowercased_equals("user-agent", value)) {
                    return .UserAgent;
                }
            },
            11 => {
                if (lowercased_equals("retry-after", value)) {
                    return .RetryAfter;
                }
            },
            12 => {
                if (lowercased_equals("content-type", value)) {
                    return .ContentType;
                } else if (lowercased_equals("max-forwards", value)) {
                    return .MaxForwards;
                }
            },
            13 => {
                if (lowercased_equals("accept-ranges", value)) {
                    return .AcceptRanges;
                } else if (lowercased_equals("authorization", value)) {
                    return .Authorization;
                } else if (lowercased_equals("cache-control", value)) {
                    return .CacheControl;
                } else if (lowercased_equals("content-range", value)) {
                    return .ContentRange;
                } else if (lowercased_equals("if-none-match", value)) {
                    return .IfNoneMatch;
                } else if (lowercased_equals("last-modified", value)) {
                    return .LastModified;
                }
            },
            14 => {
                if (lowercased_equals("content-length", value)) {
                    return .ContentLength;
                } else if (lowercased_equals("accept-charset", value)) {
                    return .AcceptCharset;
                }
            },
            15 => {
                if (lowercased_equals("accept-encoding", value)) {
                    return .AcceptEncoding;
                } else if (lowercased_equals("accept-language", value)) {
                    return .AcceptLanguage;
                } else if (lowercased_equals("public-key-pins", value)) {
                    return .PublicKeyPins;
                } else if (lowercased_equals("referrer-policy", value)) {
                    return .ReferrerPolicy;
                } else if (lowercased_equals("x-frame-options", value)) {
                    return .XFrameOptions;
                }
            },
            16 => {
                if (lowercased_equals("content-encoding", value)) {
                    return .ContentEncoding;
                } else if (lowercased_equals("content-language", value)) {
                    return .ContentLanguage;
                } else if (lowercased_equals("content-location", value)) {
                    return .ContentLocation;
                } else if (lowercased_equals("www-authenticate", value)) {
                    return .WwwAuthenticate;
                } else if (lowercased_equals("x-xss-protection", value)) {
                    return .XXssProtection;
                }
            },
            17 => {
                if (lowercased_equals("if-modified-since", value)) {
                    return .IfModifiedSince;
                } else if (lowercased_equals("sec-websocket-key", value)) {
                    return .SecWebSocketKey;
                } else if (lowercased_equals("transfer-encoding", value)) {
                    return .TransferEncoding;
                }
            },
            18 => {
                if (lowercased_equals("proxy-authenticate", value)) {
                    return .ProxyAuthenticate;
                }
            },
            19 => {
                if (lowercased_equals("content-disposition", value)) {
                    return .ContentDisposition;
                } else if (lowercased_equals("if-unmodified-since", value)) {
                    return .IfUnmodifiedSince;
                } else if (lowercased_equals("proxy-authorization", value)) {
                    return .ProxyAuthorization;
                }
            },
            20 => {
                if (lowercased_equals("sec-websocket-accept", value)) {
                    return .SecWebSocketAccept;
                }
            },
            21 => {
                if (lowercased_equals("sec-websocket-version", value)) {
                    return .SecWebSocketVersion;
                }
            },
            22 => {
                if (lowercased_equals("access-control-max-age", value)) {
                    return .AccessControlMaxAge;
                } else if (lowercased_equals("sec-websocket-protocol", value)) {
                    return .SecWebSocketProtocol;
                } else if (lowercased_equals("x-content-type-options", value)) {
                    return .XContentTypeOptions;
                } else if (lowercased_equals("x-dns-prefetch-control", value)) {
                    return .XDnsPrefetchControl;
                }
            },
            23 => {
                if (lowercased_equals("content-security-policy", value)) {
                    return .ContentSecurityPolicy;
                }
            },
            24 => {
                if (lowercased_equals("sec-websocket-extensions", value)) {
                    return .SecWebSocketExtensions;
                }
            },
            25 => {
                if (lowercased_equals("strict-transport-security", value)) {
                    return .StrictTransportSecurity;
                } else if (lowercased_equals("upgrade-insecure-requests", value)) {
                    return .UpgradeInsecureRequests;
                }
            },
            27 => {
                if (lowercased_equals("access-control-allow-origin", value)) {
                    return .AccessControlAllowOrigin;
                }
            },
            28 => {
                if (lowercased_equals("access-control-allow-headers", value)) {
                    return .AccessControlAllowHeaders;
                } else if (lowercased_equals("access-control-allow-methods", value)) {
                    return .AccessControlAllowMethods;
                }
            },
            29 => {
                if (lowercased_equals("access-control-expose-headers", value)) {
                    return .AccessControlExposeHeaders;
                } else if (lowercased_equals("access-control-request-method", value)) {
                    return .AccessControlRequestMethod;
                }
            },
            30 => {
                if (lowercased_equals("access-control-request-headers", value)) {
                    return .AccessControlRequestHeaders;
                }
            },
            32 => {
                if (lowercased_equals("access-control-allow-credentials", value)) {
                    return .AccessControlAllowCredentials;
                }
            },
            35 => {
                if (lowercased_equals("content-security-policy-report-only", value)) {
                    return .ContentSecurityPolicyReportOnly;
                }
            },
            else => {
                return .Custom;
            },
        }
        return .Custom;
    }

    pub fn as_http1(self: HeaderType, value: []const u8) []const u8 {
        return switch (self) {
            .Accept => "Accept",
            .AcceptCharset => "Accept-Charset",
            .AcceptEncoding => "Accept-Encoding",
            .AcceptLanguage => "Accept-Language",
            .AcceptRanges => "Accept-Ranges",
            .AccessControlAllowCredentials => "Access-Control-Allow-Credentials",
            .AccessControlAllowHeaders => "Access-Control-Allow-Headers",
            .AccessControlAllowMethods => "Access-Control-Allow-Methods",
            .AccessControlAllowOrigin => "Access-Control-Allow-Origin",
            .AccessControlExposeHeaders => "Access-Control-Expose-Headers",
            .AccessControlMaxAge => "Access-Control-Max-Age",
            .AccessControlRequestHeaders => "Access-Control-Request-Headers",
            .AccessControlRequestMethod => "Access-Control-Request-Method",
            .Age => "Age",
            .Allow => "Allow",
            .AltSvc => "Alt-Svc",
            .Authorization => "Authorization",
            .CacheControl => "Cache-Control",
            .Connection => "Connection",
            .ContentDisposition => "Content-Disposition",
            .ContentEncoding => "Content-Encoding",
            .ContentLanguage => "Content-Language",
            .ContentLength => "Content-Length",
            .ContentLocation => "Content-Location",
            .ContentRange => "Content-Range",
            .ContentSecurityPolicy => "Content-Security-Policy",
            .ContentSecurityPolicyReportOnly => "Content-Security-Policy-Report-Only",
            .ContentType => "Content-Type",
            .Cookie => "Cookie",
            .Custom => value,
            .Date => "Date",
            .Dnt => "Dnt",
            .Etag => "Etag",
            .Expect => "Expect",
            .Expires => "Expires",
            .Forwarded => "Forwarded",
            .From => "From",
            .Host => "Host",
            .IfMatch => "If-Match",
            .IfModifiedSince => "If-Modified-Since",
            .IfNoneMatch => "If-None-Match",
            .IfRange => "If-Range",
            .IfUnmodifiedSince => "If-Unmodified-Since",
            .LastModified => "Last-Modified",
            .Link => "Link",
            .Location => "Location",
            .MaxForwards => "Max-Forwards",
            .Origin => "Origin",
            .Pragma => "Pragma",
            .ProxyAuthenticate => "Proxy-Authenticate",
            .ProxyAuthorization => "Proxy-Authorization",
            .PublicKeyPins => "Public-Key-Pins",
            .Range => "Range",
            .Referer => "Referer",
            .ReferrerPolicy => "Referrer-Policy",
            .Refresh => "Refresh",
            .RetryAfter => "Retry-After",
            .SecWebSocketAccept => "Sec-WebSocket-Accept",
            .SecWebSocketExtensions => "Sec-WebSocket-Extensions",
            .SecWebSocketKey => "Sec-WebSocket-Key",
            .SecWebSocketProtocol => "Sec-WebSocket-Protocol",
            .SecWebSocketVersion => "Sec-WebSocket-Version",
            .Server => "Server",
            .SetCookie => "Set-Cookie",
            .StrictTransportSecurity => "Strict-Transport-Security",
            .Te => "Te",
            .Trailer => "Trailer",
            .TransferEncoding => "Transfer-Encoding",
            .UserAgent => "User-Agent",
            .Upgrade => "Upgrade",
            .UpgradeInsecureRequests => "Upgrade-Insecure-Requests",
            .Vary => "Vary",
            .Via => "Via",
            .Warning => "Warning",
            .WwwAuthenticate => "WWW-Authenticate",
            .XContentTypeOptions => "X-Content-Type-Options",
            .XDnsPrefetchControl => "X-DNS-Prefetch-Control",
            .XFrameOptions => "X-Frame-Options",
            .XXssProtection => "X-XSS-Protection",
        };
    }

    pub fn as_http2(self: HeaderType, value: []const u8) []const u8 {
        return switch (self) {
            .Accept => "accept",
            .AcceptCharset => "accept-charset",
            .AcceptEncoding => "accept-encoding",
            .AcceptLanguage => "accept-language",
            .AcceptRanges => "accept-ranges",
            .AccessControlAllowCredentials => "access-control-allow-credentials",
            .AccessControlAllowHeaders => "access-control-allow-headers",
            .AccessControlAllowMethods => "access-control-allow-methods",
            .AccessControlAllowOrigin => "access-control-allow-origin",
            .AccessControlExposeHeaders => "access-control-expose-headers",
            .AccessControlMaxAge => "access-control-max-age",
            .AccessControlRequestHeaders => "access-control-request-headers",
            .AccessControlRequestMethod => "access-control-request-method",
            .Age => "age",
            .Allow => "allow",
            .AltSvc => "alt-svc",
            .Authorization => "authorization",
            .CacheControl => "cache-control",
            .Connection => "connection",
            .ContentDisposition => "content-disposition",
            .ContentEncoding => "content-encoding",
            .ContentLanguage => "content-language",
            .ContentLength => "content-length",
            .ContentLocation => "content-location",
            .ContentRange => "content-range",
            .ContentSecurityPolicy => "content-security-policy",
            .ContentSecurityPolicyReportOnly => "content-security-policy-report-only",
            .ContentType => "content-type",
            .Cookie => "cookie",
            .Custom => value,
            .Date => "date",
            .Dnt => "dnt",
            .Etag => "etag",
            .Expect => "expect",
            .Expires => "expires",
            .Forwarded => "forwarded",
            .From => "from",
            .Host => "host",
            .IfMatch => "if-match",
            .IfModifiedSince => "if-modified-since",
            .IfNoneMatch => "if-none-match",
            .IfRange => "if-range",
            .IfUnmodifiedSince => "if-unmodified-since",
            .LastModified => "last-modified",
            .Link => "link",
            .Location => "location",
            .MaxForwards => "max-forwards",
            .Origin => "origin",
            .Pragma => "pragma",
            .ProxyAuthenticate => "proxy-authenticate",
            .ProxyAuthorization => "proxy-authorization",
            .PublicKeyPins => "public-key-pins",
            .Range => "range",
            .Referer => "referer",
            .ReferrerPolicy => "referrer-policy",
            .Refresh => "refresh",
            .RetryAfter => "retry-after",
            .SecWebSocketAccept => "sec-websocket-accept",
            .SecWebSocketExtensions => "sec-websocket-extensions",
            .SecWebSocketKey => "sec-websocket-key",
            .SecWebSocketProtocol => "sec-websocket-protocol",
            .SecWebSocketVersion => "sec-websocket-version",
            .Server => "server",
            .SetCookie => "set-cookie",
            .StrictTransportSecurity => "strict-transport-security",
            .Te => "te",
            .Trailer => "trailer",
            .TransferEncoding => "transfer-encoding",
            .UserAgent => "user-agent",
            .Upgrade => "upgrade",
            .UpgradeInsecureRequests => "upgrade-insecure-requests",
            .Vary => "vary",
            .Via => "via",
            .Warning => "warning",
            .WwwAuthenticate => "www-authenticate",
            .XContentTypeOptions => "x-content-type-options",
            .XDnsPrefetchControl => "x-dns-prefetch-control",
            .XFrameOptions => "x-frame-options",
            .XXssProtection => "x-xss-protection",
        };
    }
};

pub const HeaderName = struct {
    type: HeaderType,
    value: []const u8,

    const Error = error{
        Invalid,
    };

    pub fn parse(name: []const u8) Error!HeaderName {
        if (name.len == 0) {
            return error.Invalid;
        }

        for (name) |char| {
            if (HEADER_NAME_MAP[char] == 0) {
                return error.Invalid;
            }
        }
        return HeaderName{ .type = HeaderType.from_bytes(name), .value = name };
    }

    pub inline fn raw(self: HeaderName) []const u8 {
        return self.value;
    }

    pub inline fn as_http1(self: HeaderName) []const u8 {
        return self.type.as_http1(self.value);
    }

    pub inline fn as_http2(self: HeaderName) []const u8 {
        return self.type.as_http2(self.value);
    }

    pub fn type_of(name: []const u8) HeaderType {
        return HeaderType.from_bytes(name);
    }
};

// ASCII codes accepted for an header's name
// Cf: Borrowed from Seamonstar's httparse library
// https://github.com/seanmonstar/httparse/blob/01e68542605d8a24a707536561c27a336d4090dc/src/lib.rs#L96
const HEADER_NAME_MAP = [_]u8{
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    //  \0                         \t \n       \r
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    //   commands
    0,   '!', 0,   '#', '$', '%', '&', '\'', 0,   0,   '*', '+', 0,   '-', '.', 0,
    //  \s      "                            (  )            ,            /
    '0', '1', '2', '3', '4', '5', '6', '7',  '8', '9', 0,   0,   0,   0,   0,   0,
    //                                                    :  ;  <  =  >  ?
    0,   'a', 'b', 'c', 'd', 'e', 'f', 'g',  'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    //  @   A    B    C    D    E    F    G    H    I    J    K    L    M    N    O
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w',  'x', 'y', 'z', 0,   0,   0,   '^', '_',
    //   P    Q    R    S    T    U    V    W    X    Y    Z   [  \  ]
    '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g',  'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    //
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w',  'x', 'y', 'z', 0,   '|', 0,   '~', 0,
    //                                                         {       }      del
    //   ====== Extended ASCII (aka. obs-text) ======
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,    0,   0,   0,   0,   0,   0,   0,   0,
};
