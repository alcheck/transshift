//
//  RPCConnector.m
//  TransmissionRPCClient
//

#import <UIKit/UIKit.h>
#import "RPCConnector.h"
#import "RPCConfigValues.h"

#define HTTP_RESPONSE_OK                    200
#define HTTP_RESPONSE_UNAUTHORIZED          401
#define HTTP_RESPONSE_NEED_X_TRANS_ID       409
#define HTTP_REQUEST_METHOD                 @"POST"
#define HTTP_AUTH_HEADER                    @"Authorization"
#define HTTP_XTRANSID_HEADER                @"X-Transmission-Session-Id"

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
                        TR_ARG_FIELDS_ETA,
                        TR_ARG_FIELDS_SEEDRATIOMODE,
                        TR_ARG_FIELDS_SEEDIDLEMODE,
                        TR_ARG_FIELDS_UPLOADLIMITED,
                        TR_ARG_FIELDS_DOWNLOADLIMITED,
                        TR_ARG_FIELDS_HAVEVALID
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
                                                  TR_ARG_FIELDS_BANDWIDTHPRIORITY,
                                                  TR_ARG_FIELDS_QUEUEPOSITION,
                                                  TR_ARG_FIELDS_HONORSSESSIONLIMITS,
                                                  TR_ARG_FIELDS_SEEDIDLELIMIT,
                                                  TR_ARG_FIELDS_SEEDIDLEMODE,
                                                  TR_ARG_FIELDS_SEEDRATIOLIMIT,
                                                  TR_ARG_FIELDS_SEEDRATIOMODE,
                                                  TR_ARG_FIELDS_UPLOADLIMIT,
                                                  TR_ARG_FIELDS_UPLOADLIMITED,
                                                  TR_ARG_FIELDS_DOWNLOADLIMIT,
                                                  TR_ARG_FIELDS_DOWNLOADLIMITED,
                                                  TR_ARG_FIELDS_DOWNLOADDIR
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

- (void)getMagnetURLforTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{ TR_ARG_FIELDS : @[ TR_ARG_FIELDS_MAGNETLINK ],  TR_ARG_IDS : @[@(torrentId)] }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSString *magnetUrlString = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_MAGNETLINK];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotMagnetURL:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotMagnetURL:magnetUrlString forTorrentWithId:torrentId];
             });
     }];
}


- (void)getAllPeersForTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_PEERS, TR_ARG_FIELDS_PEERSFROM ],
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
         
         TRPeerStat *peerStat = [TRPeerStat peerStatWithJSONData:[torrentsJsonDesc firstObject][TR_ARG_FIELDS_PEERSFROM]];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllPeers:withPeerStat:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllPeers:peerInfos withPeerStat:peerStat forTorrentWithId:torrentId];
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
         
         NSArray* files = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_FILES];
         NSArray* fileStats = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_FILESTATS];
         
         // ** Benchmarking **
         //CFTimeInterval tmStart = CACurrentMediaTime();
         // --------------------------------------------
         FSDirectory *fsDir = [FSDirectory directory];
         
         for( int i = 0; i < files.count; i++ )
             [fsDir addItemWithJSONFileInfo:files[i] JSONFileStatInfo:fileStats[i] rpcIndex:i];
         
         // --------------------------------------------
         //CFTimeInterval tmEnd = CACurrentMediaTime();
         //NSLog( @"%s, run time: %g s", __PRETTY_FUNCTION__,  tmEnd - tmStart );
         
         
         [fsDir sort];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllFiles:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllFiles:fsDir forTorrentWithId:torrentId];
             });
     }];    
}

- (void)getAllFileStatsForTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{ TR_ARG_FIELDS : @[ TR_ARG_FIELDS_FILESTATS], TR_ARG_IDS : @[@(torrentId)] }
                                 };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrents = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         NSArray* fileStats = [torrents firstObject][TR_ARG_FIELDS_FILESTATS];
         
         NSMutableArray *res = [NSMutableArray array];
         
         for( NSDictionary *fileStatJSON in fileStats )
         {
             TRFileStat *fileStat = [TRFileStat fileStatFromJSON:fileStatJSON];
             [res addObject:fileStat];
         }
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllFileStats:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllFileStats:res forTorrentWithId:torrentId];
             });
     }];
}

- (void)getAllTrackersForTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_TRACKERSTATS ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSArray* trackerStats = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_TRACKERSTATS];
         
         NSMutableArray *res = [NSMutableArray array];
         
         for( NSDictionary *dict in trackerStats )
             [res addObject:[TrackerStat initFromJSON:dict]];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllTrackers:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllTrackers:res forTorrentWithId:torrentId];
             });
     }];
}

- (void)getPiecesBitMapForTorrent:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_PIECES ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSString* base64data = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_PIECES];
 
         NSData *data = [[NSData alloc] initWithBase64EncodedString:base64data options:NSDataBase64DecodingIgnoreUnknownCharacters];
         
         if( _delegate && [_delegate respondsToSelector:@selector(gotPiecesBitmap:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotPiecesBitmap:data forTorrentWithId:torrentId];
             });
     }];
}


- (void)removeTracker:(int)trackerId forTorrent:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS_TRACKERREMOVE : @[ @(trackerId) ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTrackerRemoved:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTrackerRemoved:trackerId forTorrentWithId:torrentId];
             });
     }];
}

- (void)setSettings:(TRInfo *)info forTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS_QUEUEPOSITION : @(info.queuePosition),
                                          TR_ARG_FIELDS_BANDWIDTHPRIORITY : @(info.bandwidthPriority),
                                          TR_ARG_FIELDS_UPLOADLIMITED : @(info.uploadLimitEnabled),
                                          TR_ARG_FIELDS_UPLOADLIMIT : @(info.uploadLimit),
                                          TR_ARG_FIELDS_DOWNLOADLIMITED : @(info.downloadLimitEnabled),
                                          TR_ARG_FIELDS_DOWNLOADLIMIT : @(info.downloadLimit),
                                          TR_ARG_FIELDS_SEEDIDLEMODE : @(info.seedIdleMode),
                                          TR_ARG_FIELDS_SEEDIDLELIMIT : @(info.seedIdleLimit),
                                          TR_ARG_FIELDS_SEEDRATIOMODE : @(info.seedRatioMode),
                                          TR_ARG_FIELDS_SEEDRATIOLIMIT : @(info.seedRatioLimit),
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotSetSettingsForTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotSetSettingsForTorrentWithId:torrentId];
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

- (void)stopAllTorrents
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_TORRENTSTOP };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSTOP andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotAllTorrentsStopped)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAllTorrentsStopped];
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

- (void)resumeAllTorrents
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_TORRENTRESUME };
      
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTRESUME andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotAlltorrentsResumed)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotAlltorrentsResumed];
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


- (void)renameTorrent:(int)torrentId withName:(NSString *)name andPath:(NSString *)path
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSETNAME,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_NAME : name, TR_ARG_FIELDS_PATH: path }
                                  };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSETNAME andHandler:^(NSDictionary *json)
     {
         if( _delegate && [_delegate respondsToSelector:@selector(gotTorrentRenamed:withName:andPath:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotTorrentRenamed:torrentId withName:name andPath:path];
             });
     }];
}



- (void)addTorrentWithData:(NSData *)data
                  priority:(int)priority
          startImmidiately:(BOOL)startImmidiately
           indexesUnwanted:(NSArray*)idxUnwanted
{
    NSString *base64content = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_METAINFO : base64content,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES),
                                                      TR_ARG_FIELDS_FILES_UNWANTED : idxUnwanted
                                                    }
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
         if( _delegate && [_delegate respondsToSelector:@selector(gotFilesStoppedToDownload:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_delegate gotFilesStoppedToDownload:indexes forTorrentWithId:torrentId];
             });
     }];
}

- (void)resumeDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_FILES_WANTED : indexes } };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
                  if( _delegate && [_delegate respondsToSelector:@selector(gotFilesResumedToDownload:forTorrentWithId:)])
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [_delegate gotFilesResumedToDownload:indexes forTorrentWithId:torrentId];
                      });
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

/// toggle alternative limits mode
- (void)toggleAltLimitMode:(BOOL)altLimitsEnabled
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET,
                                   TR_METHOD_ARGS : @{ TR_ARG_SESSION_ALTLIMITRATEENABLED : @(altLimitsEnabled) } };
    
    [self makeRequest:requestVals withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json)
    {
        if( _delegate && [_delegate respondsToSelector:@selector(gotToggledAltLimitMode:)] )
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate gotToggledAltLimitMode:altLimitsEnabled];
            });
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
    
    if( _config.xTransSessionId )
        [req addValue: _config.xTransSessionId forHTTPHeaderField:HTTP_XTRANSID_HEADER];
    
    // JSON request
    //req.HTTPBody = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
    
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestDict options:kNilOptions error:NULL];
    req.timeoutInterval = _config.requestTimeout;
    
    // preform one request at a time
//    if( _task )
//        [_task cancel];
    
    _task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
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
                    else if( statusCode == HTTP_RESPONSE_NEED_X_TRANS_ID )
                    {
                        _config.xTransSessionId = httpResponse.allHeaderFields[HTTP_XTRANSID_HEADER];
                        [self makeRequest:requestDict withName:requestName andHandler:dataHandler];
                        return;
                    }
                    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
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
            _authString = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
        }
    }
    
    return  self;
}

@end
