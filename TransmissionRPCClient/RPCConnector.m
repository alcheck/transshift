//
//  RPCConnector.m
//  TransmissionRPCClient
//

#import <UIKit/UIKit.h>
#import "RPCConnector.h"
#import "RPCConfigValues.h"

#define HTTP_RESPONSE_OK                    200
#define HTTP_RESPONSE_UNAUTHORIZED          401
#define HTTP_REQUEST_METHOD                 @"POST"
#define HTTP_AUTH_HEADER                    @"Authorization"

@implementation RPCConnector

{
    RPCServerConfig *_config;                       // holds config
    __weak id<RPCConnectorDelegate> _delegate;      // hodls delegate
    NSURLSession    *_session;                      // holds session
    NSString        *_authString;                   // holds auth info or nil
    NSURL           *_url;
    
    NSURLSessionDataTask *_task;                    // holds current data task
}

// get all torrents and save them in array
- (void)getAllTorrents
{
    NSDictionary *requestVals = @{
        TR_METHOD : TR_METHODNAME_TORRENTGET,
        TR_METHOD_ARGS : @{
                TR_ARG_FIELDS : @[
                        TR_ARG_FIELDS_ID,
                        TR_ARG_FIELDS_NAME,
                        TR_ARG_FIELDS_STATUS,
                        TR_ARG_FIELDS_ERRORNUM,
                        TR_ARG_FIELDS_ERRORSTRING,
                        TR_ARG_FIELDS_TOTALSIZE,
                        TR_ARG_FIELDS_PERCENTDONE,
                        TR_ARG_FIELDS_RATEDOWNLOAD,
                        TR_ARG_FIELDS_RATEUPLOAD,
                        TR_ARG_FIELDS_PEERSCONNECTED,
                        TR_ARG_FIELDS_PEERSGETTINGFROMUS,
                        TR_ARG_FIELDS_PEERSSENDINGTOUS,
                        TR_ARG_FIELDS_UPLOADEDEVER,
                        TR_ARG_FIELDS_UPLOADRATIO,
                        TR_ARG_FIELDS_RECHECKPROGRESS,
                        TR_ARG_FIELDS_DOWNLOADEDEVER,
                        TR_ARG_FIELDS_ETA
                    ]
        }
    };
   
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
    {
        // save torrents and call delegate
        NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
        
        TRInfos *trInfos = [TRInfos infosFromArrayOfJSON:torrentsJsonDesc];

        if( _delegate && [_delegate respondsToSelector:@selector(gotAllTorrents:)])
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate gotAllTorrents:trInfos];
            });
    }];
}

// request detailed info for torrent with id - torrentId
- (void)getDetailedInfoForTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[
                                                  TR_ARG_FIELDS_ID,
                                                  TR_ARG_FIELDS_NAME,
                                                  TR_ARG_FIELDS_STATUS,
                                                  TR_ARG_FIELDS_TOTALSIZE,
                                                  TR_ARG_FIELDS_PERCENTDONE,
                                                  TR_ARG_FIELDS_RATEDOWNLOAD,
                                                  TR_ARG_FIELDS_RATEUPLOAD,
                                                  TR_ARG_FIELDS_PEERSCONNECTED,
                                                  TR_ARG_FIELDS_PEERSGETTINGFROMUS,
                                                  TR_ARG_FIELDS_PEERSSENDINGTOUS,
                                                  TR_ARG_FIELDS_UPLOADEDEVER,
                                                  TR_ARG_FIELDS_UPLOADRATIO,
                                                  TR_ARG_FIELDS_ACTIVITYDATE,
                                                  TR_ARG_FIELDS_COMMENT,
                                                  TR_ARG_FIELDS_CREATOR,
                                                  TR_ARG_FIELDS_DATECREATED,
                                                  TR_ARG_FIELDS_DONEDATE,
                                                  TR_ARG_FIELDS_ERRORNUM,
                                                  TR_ARG_FIELDS_ERRORSTRING,
                                                  TR_ARG_FIELDS_HASHSTRING,
                                                  TR_ARG_FIELDS_PIECECOUNT,
                                                  TR_ARG_FIELDS_PIECESIZE,
                                                  TR_ARG_FIELDS_SECONDSDOWNLOADING,
                                                  TR_ARG_FIELDS_SECONDSSEEDING,
                                                  TR_ARG_FIELDS_STARTDATE,
                                                  TR_ARG_FIELDS_HAVEVALID,
                                                  TR_ARG_FIELDS_HAVEUNCHECKED,
                                                  TR_ARG_FIELDS_RECHECKPROGRESS,
                                                  TR_ARG_FIELDS_DOWNLOADEDEVER,
                                                  TR_ARG_FIELDS_ETA,
                                                  TR_ARG_BANDWIDTHPRIORITY
                                                  ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         TRInfo *trInfo = [TRInfo infoFromJSON:[torrentsJsonDesc firstObject]];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentDetailedInfo:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentDetailedInfo:trInfo];
             });
     }];
}

- (void)getAllPeersForTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_PEERS ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSMutableArray *peerInfos = [NSMutableArray array];
         
         for( NSDictionary* peerJsonDict in [torrentsJsonDesc firstObject][TR_ARG_FIELDS_PEERS] )
             [peerInfos addObject:[TRPeerInfo peerInfoWithJSONData:peerJsonDict]];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllPeers:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllPeers:peerInfos forTorrentWithId:torrentId];
             });
     }];
}

- (void)getAllFilesForTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_FILES, TR_ARG_FIELDS_FILESTATS],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSMutableArray *fileInfos = [NSMutableArray array];
         
         NSArray* files = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_FILES];
         NSArray* fileStats = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_FILESTATS];
         
         for( int i = 0; i < files.count; i++ )
         {
             NSMutableDictionary* file = [NSMutableDictionary dictionaryWithDictionary: files[i]];
             NSDictionary* fileStat = fileStats[i];
             
             if( fileStat[TR_ARG_FILEINFO_PRIORITY] )
                 file[TR_ARG_FILEINFO_PRIORITY] = fileStat[TR_ARG_FILEINFO_PRIORITY];
             if( fileStat[TR_ARG_FILEINFO_WANTED] )
                 file[TR_ARG_FILEINFO_WANTED] = fileStat[TR_ARG_FILEINFO_WANTED];
             
             [fileInfos addObject:[TRFileInfo fileInfoFromJSON:file]];
         }
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllFiles:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllFiles:fileInfos forTorrentWithId:torrentId];
             });
     }];    
}

- (void)stopTorrent:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSTOP,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)] }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSTOP andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentStopedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentStopedWithId:torrentId];
             });
     }];
}

- (void)resumeTorrent:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTRESUME,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)] }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTRESUME andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentResumedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentResumedWithId:torrentId];
             });
     }];
}

- (void)verifyTorrent:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTVERIFY,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)] }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTVERIFY andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentVerifyedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentVerifyedWithId:torrentId];
             });
     }];
}

- (void)reannounceTorrent:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTREANNOUNCE,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)] }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTREANNOUNCE andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentReannouncedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentReannouncedWithId:torrentId];
             });
     }];
}

- (void)deleteTorrentWithId:(int)torrentId deleteWithData:(BOOL)deleteWithData
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTREMOVE,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_DELETELOCALDATA:@(deleteWithData) }};
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTREMOVE andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentDeletedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentDeletedWithId:torrentId];
             });
     }];
}

- (void)addTorrentWithData:(NSData *)data priority:(int)priority startImmidiately:(BOOL)startImmidiately
{
    NSString *base64content = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_METAINFO : base64content,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES) }	
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTADD andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentAdded)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentAdded];
             });
     }];

}

- (void)addTorrentWithMagnet:(NSString *)magnetURLString priority:(int)priority startImmidiately:(BOOL)startImmidiately
{    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_MAGNETFILENAME : magnetURLString,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES) }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTADDURL andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentAddedWithMagnet:)])
         {
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 [_delegate gotTorrentAddedWithMagnet:magnetURLString];
             });
         }
         else if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentAdded)])
         {
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 [_delegate gotTorrentAdded];
             });
         }
     }];
    
}

- (void)stopDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_FILES_UNWANTED : indexes } };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
//         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentDeletedWithId:)])
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [_delegate gotTorrentDeletedWithId:torrentId];
//             });
     }];
}

- (void)resumeDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_FILES_WANTED : indexes } };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         //         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentDeletedWithId:)])
         //             dispatch_async(dispatch_get_main_queue(), ^{
         //                 [_delegate gotTorrentDeletedWithId:torrentId];
         //             });
     }];
}

- (void)setPriority:(int)priority forFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    NSArray *argNames = @[TR_ARG_FIELDS_FILES_PRIORITY_LOW, TR_ARG_FIELDS_FILES_PRIORITY_NORMAL, TR_ARG_FIELDS_FILES_PRIORITY_HIGH];
    
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], argNames[priority + 1] : indexes } };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         //         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentDeletedWithId:)])
         //             dispatch_async(dispatch_get_main_queue(), ^{
         //                 [_delegate gotTorrentDeletedWithId:torrentId];
         //             });
     }];
}

- (void)getSessionInfo
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONGET };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_SESSIONGET andHandler:^(NSDictionary *json)
    {
         NSDictionary *sessionJSON = json[TR_RETURNED_ARGS];
         TRSessionInfo *sessionInfo = [TRSessionInfo sessionInfoFromJSON:sessionJSON];

         if( _delegate && [_delegate respondsToSelector:@selector(gotSessionWithInfo:)])
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [_delegate gotSessionWithInfo:sessionInfo];
                      });
    }];    
}

- (void)setSessionWithSessionInfo:(TRSessionInfo *)info
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET, TR_METHOD_ARGS : info.jsonForRPC };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotSessionSetWithInfo:)] )
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotSessionSetWithInfo: info];
                 //[self getSessionInfo];
             });
     }];
}

// if rateKBs is 0 - limit is disabled
- (void)limitDownloadRateWithSpeed:(int)rateKbs
{
    BOOL isEnabled = rateKbs > 0;
    
    NSDictionary* args;
    
    if( isEnabled )
        args = @{ TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO), TR_ARG_SESSION_LIMITDOWNRATEENABLED : @(YES), TR_ARG_SESSION_LIMITDOWNRATE : @(rateKbs) };
    else
        args = @{ TR_ARG_SESSION_LIMITDOWNRATEENABLED : @(NO), TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO) };

    
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET, TR_METHOD_ARGS : args };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json){
        [self getSessionInfo];
    }];
}

// if rateKBs si 0 - limit is disabled
- (void)limitUploadRateWithSpeed:(int)rateKbs
{
    BOOL isEnabled = rateKbs > 0;
   
    NSDictionary* args;
    
    if( isEnabled )
        args = @{ TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO), TR_ARG_SESSION_LIMITUPRATEENABLED : @(YES), TR_ARG_SESSION_LIMITUPRATE : @(rateKbs) };
    else
        args = @{ TR_ARG_SESSION_LIMITUPRATEENABLED : @(NO), TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO) };

    
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET, TR_METHOD_ARGS : args };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json){
        [self getSessionInfo];
    }];
}

- (void)getFreeSpaceWithDownloadDir:(NSString *)downloadDir
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_FREESPACE,
                                  TR_METHOD_ARGS : @{ TR_ARG_FREESPACEPATH : downloadDir } };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_FREESPACE andHandler:^(NSDictionary *json)
     {
         long long freeSizeBytes = [(NSNumber*)(json[TR_RETURNED_ARGS][TR_ARG_FREESPACESIZE]) longLongValue];

         NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
         formatter.allowsNonnumericFormatting = NO;
         NSString* freeSizeString = [formatter stringFromByteCount:freeSizeBytes];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotFreeSpaceString:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotFreeSpaceString:freeSizeString];
             });
     }];
}

- (void)portTest
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_TESTPORT };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TESTPORT andHandler:^(NSDictionary *json)
     {
         BOOL portIsOpen = [(NSNumber*)(json[TR_RETURNED_ARGS][TR_ARG_PORTTESTPORTISOPEN]) boolValue];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotPortTestedWithSuccess:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotPortTestedWithSuccess:portIsOpen];
             });
     }];
}

// perform request with JSON body and handler
- (void)makeRequest:(NSDictionary*)requestDict withName:(NSString*)requestName andHandler:( void (^)( NSDictionary* )) dataHandler
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
    req.HTTPMethod = HTTP_REQUEST_METHOD;
    
    // add authorization header
    if( _authString )
        [req addValue:_authString forHTTPHeaderField: HTTP_AUTH_HEADER];
    
    // JSON request
    //req.HTTPBody = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
    
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestDict options:kNilOptions error:NULL];
    req.timeoutInterval = _config.requestTimeout;
    
    // preform one request at a time
//    if( _task )
//        [_task cancel];
    
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
                NSInteger statusCode = httpResponse.statusCode;
                
                if ( httpResponse.statusCode != HTTP_RESPONSE_OK )
                {
                    _lastErrorMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
                    if( statusCode == HTTP_RESPONSE_UNAUTHORIZED )
                        _lastErrorMessage = NSLocalizedString(@"You are unauthorized to access server", @"");
                    
                    [self sendErrorMessage:[NSString stringWithFormat:@"%li %@", (long)statusCode, _lastErrorMessage]
                          toDelegateWithRequestMethodName:requestName];
                }
                else
                {
                    // response OK
                    // trying to deserialize answer data as JSNO object
                    NSDictionary *ansJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if( !ansJSON )
                    {
                        [self sendErrorMessage:NSLocalizedString(@"Server response wrong data", @"")
                              toDelegateWithRequestMethodName:requestName];
                    }
                    // JSON is OK, trying to retrieve result of request it should be TR_RESULT_SUCCEED
                    else
                    {
                        NSString *result =  ansJSON[TR_RESULT];
                        if( !result )
                        {
                            [self sendErrorMessage:NSLocalizedString(@"Server failed to return data", @"")
                                  toDelegateWithRequestMethodName:requestName];
                        }
                        else if( ![result isEqualToString: TR_RESULT_SUCCEED] )
                        {
                            [self sendErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"Server failed to return data: %@", @""), result]
                                  toDelegateWithRequestMethodName:requestName];
                        }
                        else
                        {
                            // server returned SUCCESS
                            dataHandler( ansJSON );
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
