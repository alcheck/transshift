//
//  RPCServerConfig.m
//  Holds transmission remote rpc settings

#import "RPCServerConfig.h"

static NSString * const CODER_NAME = @"name";
static NSString * const CODER_RPC_PATH = @"path";
static NSString * const CODER_USER_NAME = @"username";
static NSString * const CODER_USER_PASSWORD = @"pass";
static NSString * const CODER_PORT = @"port";
static NSString * const CODER_HOST = @"host";
static NSString * const CODER_USE_SSL = @"ssl";
static NSString * const CODER_REFRESH_TIMEOUT = @"time";
static NSString * const CODER_REQUEST_TIMEOUT = @"reqtimeout";
static NSString * const CODER_SHOW_FREESPACE = @"showFreeSpace";

@implementation RPCServerConfig

// init with default params
- (instancetype)init
{
    self = [super init];
    if( self )
    {
        _name = RPC_DEFAULT_NAME;
        _host = RPC_DEFAULT_HOST;
        _port = RPC_DEFAULT_PORT;
        _useSSL = RPC_DEFAULT_USE_SSL;
        _rpcPath = RPC_DEFAULT_PATH;
        _refreshTimeout = RPC_DEFAULT_REFRESH_TIME;
        _requestTimeout = RPC_DEFAULT_REQUEST_TIMEOUT;
        _showFreeSpace = RPC_DEFAULT_SHOWFREESPACE;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"RPCServerConfig[%@://%@:%i%@, refresh:%is, request timeout: %is]",
            _useSSL ? @"https" : @"http",
            _host,
            _port,
            _rpcPath,
            _refreshTimeout,
            _requestTimeout ];
}

- (NSString *)urlString
{
    if( ![_rpcPath hasPrefix:@"/"] )
        _rpcPath = [NSString stringWithFormat:@"/%@", _rpcPath];
    
    return [NSString stringWithFormat:@"%@://%@:%i%@", _useSSL ? @"https" : @"http", _host, _port, _rpcPath];
}

#pragma mark - NSCoding protocol imp

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if( self )
    {
        _name = [aDecoder decodeObjectForKey:CODER_NAME];
        _rpcPath = [aDecoder decodeObjectForKey:CODER_RPC_PATH];
        _userName = [aDecoder decodeObjectForKey:CODER_USER_NAME];
        _userPassword = [aDecoder decodeObjectForKey:CODER_USER_PASSWORD];
        _port = [aDecoder decodeIntForKey:CODER_PORT];
        _host = [aDecoder decodeObjectForKey:CODER_HOST];
        _useSSL = [aDecoder decodeBoolForKey:CODER_USE_SSL];
        _refreshTimeout = [aDecoder decodeIntForKey:CODER_REFRESH_TIMEOUT];
        _requestTimeout = [aDecoder decodeIntForKey:CODER_REQUEST_TIMEOUT];
        _showFreeSpace = [aDecoder decodeBoolForKey:CODER_SHOW_FREESPACE];
    }
    
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:CODER_NAME];
    [coder encodeObject:self.rpcPath forKey:CODER_RPC_PATH];
    [coder encodeObject:self.host forKey:CODER_HOST];
    [coder encodeObject:self.userName forKey:CODER_USER_NAME];
    [coder encodeObject:self.userPassword forKey: CODER_USER_PASSWORD];
    [coder encodeInt:self.port forKey:CODER_PORT];
    [coder encodeInt:self.refreshTimeout forKey: CODER_REFRESH_TIMEOUT];
    [coder encodeInt:self.requestTimeout forKey:CODER_REQUEST_TIMEOUT];
    [coder encodeBool:self.useSSL forKey:CODER_USE_SSL];
    [coder encodeBool:self.showFreeSpace forKey:CODER_SHOW_FREESPACE];
}

- (NSDictionary *)plist
{
    NSDictionary *pList = @{
                            CODER_NAME : _name,
                            CODER_RPC_PATH : _rpcPath,
                            CODER_HOST : _host,
                            CODER_PORT : @(_port),
                            CODER_USE_SSL : @(_useSSL),
                            CODER_USER_NAME : _userName,
                            CODER_USER_PASSWORD : _userPassword,
                            CODER_REFRESH_TIMEOUT : @(_refreshTimeout),
                            CODER_REQUEST_TIMEOUT : @(_refreshTimeout),
                            CODER_SHOW_FREESPACE : @(_showFreeSpace)
                            };
    
    return pList;
}

- (instancetype)initFromPList:(NSDictionary *)plist
{
    self = [super init];
    if( self )
    {
        _name = plist[CODER_NAME];
        _rpcPath = plist[CODER_RPC_PATH];
        _host = plist[CODER_HOST];
        _port = [(NSNumber*)plist[CODER_PORT] intValue];
        _useSSL = [(NSNumber*)plist[CODER_USE_SSL] boolValue];
        _userName = plist[CODER_USER_NAME];
        _userPassword = plist[CODER_USER_PASSWORD];
        _refreshTimeout = [(NSNumber*)plist[CODER_REFRESH_TIMEOUT] intValue];
        _requestTimeout = [(NSNumber*)plist[CODER_REQUEST_TIMEOUT] intValue];
        _showFreeSpace = [plist[CODER_SHOW_FREESPACE] boolValue];
    }
    
    return self;
}

@end
