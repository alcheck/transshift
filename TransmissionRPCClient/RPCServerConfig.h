//
//  RPCServerConfig.h
//  Holds transmission remote rpc settings
//

#import <Foundation/Foundation.h>

#define RPC_DEFAULT_PORT                8090
#define RPC_DEFAULT_PATH                @"/transmission/rpc"
#define RPC_DEFAULT_REFRESH_TIME        5
#define RPC_DEFAULT_REQUEST_TIMEOUT     10
#define RPC_DEFAULT_USE_SSL             NO
#define RPC_DEFAULT_NAME                @"?"
#define RPC_DEFAULT_HOST                @"?"
#define RPC_DEFAULT_SHOWFREESPACE       YES

@interface RPCServerConfig : NSObject <NSCoding>

- (instancetype)initFromPList:(NSDictionary*)plist;

@property(nonatomic) NSString *name;            // common server name
@property(nonatomic) NSString *host;            // ip address of domain name of server
@property(nonatomic) int       port;            // RPC port to connect to (default 8090)
@property(nonatomic) NSString *rpcPath;         // rpc path (default /transmission/remote/rpc
@property(nonatomic) NSString *userName;        // http basic auth user name
@property(nonatomic) NSString *userPassword;    // http basic auth password
@property(nonatomic) BOOL      useSSL;          // use https
@property(nonatomic) BOOL      showFreeSpace;   // update free space on server info
@property(nonatomic) int       refreshTimeout;  // refresh time in seconds
@property(nonatomic) int       requestTimeout;  // request timeout to server in seconds
@property(nonatomic,readonly)  NSString* urlString; // return short descriptions of class
@property(nonatomic) NSString *xTransSessionId; // transmission session id

@property(nonatomic,readonly) NSDictionary* plist; // return property list object

@end
