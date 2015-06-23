//
//  RPCServerConfig.m
//  Holds transmission remote rpc settings

#import "RPCServerConfig.h"

static NSString *CODER_NAME = @"name";
static NSString *CODER_RPC_PATH = @"path";
static NSString *CODER_USER_NAME = @"username";
static NSString *CODER_USER_PASSWORD = @"pass";
static NSString *CODER_PORT = @"port";
static NSString *CODER_HOST = @"host";
static NSString *CODER_USE_SSL = @"ssl";
static NSString *CODER_REFRESH_TIME = @"time";
static NSString *CODER_REQUEST_TIMEOUT = @"reqtimeout";

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
        _refreshTime = RPC_DEFAULT_REFRESH_TIME;
        _requestTimeout = RPC_DEFAULT_REQUEST_TIMEOUT;
    }
    
    return self;
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
        _refreshTime = [aDecoder decodeIntForKey:CODER_REFRESH_TIME];
        _requestTimeout = [aDecoder decodeIntForKey:CODER_REQUEST_TIMEOUT];
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
    [coder encodeInt:self.refreshTime forKey: CODER_REFRESH_TIME];
    [coder encodeInt:self.requestTimeout forKey:CODER_REQUEST_TIMEOUT];
    [coder encodeBool:self.useSSL forKey:CODER_USE_SSL];
}

@end
