//
//  RPCConnector.m
//  TransmissionRPCClient
//


#import "RPCConnector.h"
#import <UIKit/UIKit.h>

#define HTTP_RESPONSE_OK                    200
#define HTTP_RESPONSE_UNAUTHORIZED          401

@implementation RPCConnector

{
    RPCServerConfig *_config;                       // holds config
    __weak id<RPCConnectorDelegate> _delegate;      // hodls delegate
    NSURLSession    *_session;                      // holds session
    NSString        *_authString;                   // holds auth info or nil
    NSURL           *_url;
    
    NSURLSessionDataTask *_task;
}

// get all torrents and save them in array
- (void)getAllTorrents
{
    NSString *req = @"{\"method\":\"torrent-get\", \
    \"arguments\": \
    {\"fields\": \
    [\"id\",\
     \"name\", \
     \"status\" \
    ]}}";
    
    
    [self makeRequest:req withName:RPC_COMMAND_GETALLTORRENTS andHandler:^(NSDictionary *json) {

        // save torrents and call delegate
        NSArray *torrentDesc = json[@"arguments"][@"torrents"];
        if( _delegate && [_delegate respondsToSelector:@selector(gotAllTorrents:)])
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate gotAllTorrents:torrentDesc];
            });
    }];
}

// perform request with JSON body and handler
- (void)makeRequest:(NSString*)httpBody withName:(NSString*)requestName andHandler:( void (^)( NSDictionary* )) handlerBlock
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
    req.HTTPMethod = @"POST";
    if( _authString )
        [req addValue:_authString forHTTPHeaderField:@"Authorization"];
    
    // JSON request
    req.HTTPBody = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
    req.timeoutInterval = _config.requestTimeout;
    
    // preform one request at a time
    if( _task )
        [_task cancel];
        
    _task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // code goes here
        if( error )
        {
            [self sendErrorMessage:error.localizedDescription toDelegateWithRequestMethodName:requestName];
        }
        else
        {
            // check if if response not 200
            if( [response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                int statusCode = httpResponse.statusCode;
                
                if ( httpResponse.statusCode != HTTP_RESPONSE_OK )
                {
                    _lastErrorMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
                    if( statusCode == HTTP_RESPONSE_UNAUTHORIZED )
                        _lastErrorMessage = @"You are unauthorized to access server";
                    
                    [self sendErrorMessage:[NSString stringWithFormat:@"%i %@", statusCode, _lastErrorMessage]toDelegateWithRequestMethodName:requestName];
                }
                else
                {
                    // response OK - we need to check status
                    // deserialize object
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if( !json )
                    {
                        [self sendErrorMessage:@"Server response wrong data" toDelegateWithRequestMethodName:requestName];
                        return;
                    }
                    else
                    {
                        NSString *result =  json[@"result"];
                        if( !result )
                        {
                            [self sendErrorMessage:@"Server failed to return data" toDelegateWithRequestMethodName:requestName];
                            return;
                        }
                        else if( ![result isEqualToString:@"success"] )
                        {
                            [self sendErrorMessage:[NSString stringWithFormat:@"Server failed to return data: %@", result]
                                    toDelegateWithRequestMethodName:requestName];
                            return;
                        }
                        else
                        {
                            // server returned SUCCESS
                            handlerBlock( json );
                        }
                    }
                }
            }
        }
    }];
    
    // start activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_task resume];
}

- (void)stopRequests
{
    if( _task )
        [_task cancel];
}

- (void)sendErrorMessage:(NSString*)message toDelegateWithRequestMethodName:(NSString*)methodName
{
    _lastErrorMessage = message;
    if( _delegate && [_delegate respondsToSelector:@selector(connector:complitedRequestName:withError:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate connector:self complitedRequestName:methodName withError:message ];
        });
    }
}


- (instancetype)initWithConfig:(RPCServerConfig *)config andDelegate:(id<RPCConnectorDelegate>)delegate
{
    self = [super init];
    
    if( self )
    {
        _config = config;
        _delegate = delegate;
        
        // create nsurlsession with our config parameters
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = config.requestTimeout;
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig];
        _url = [NSURL URLWithString:config.urlString];
        
        // add auth header if there is username
        _authString = nil;
        if( config.userName )
        {
            if( !config.userPassword )
                config.userPassword = @"";
            
            NSString *authStringToEncode64 = [NSString stringWithFormat:@"%@:%@", config.userName, config.userPassword];
            NSData *data = [authStringToEncode64 dataUsingEncoding:NSUTF8StringEncoding];
            _authString = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
        }
    }
    
    return  self;
}

@end
