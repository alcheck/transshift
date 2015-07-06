//
//  TRSessionInfo.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRSessionInfo.h"

@interface TRSessionInfo()

@property(nonatomic,readonly) NSString*     transmissionVersion;
@property(nonatomic,readonly) NSString*     rpcVersion;
@property(nonatomic,readonly) NSString*     downloadDir;

@property(nonatomic,readonly) BOOL          startDownloadingOnAdd;

@property(nonatomic,readonly) BOOL          upLimitEnabled;
@property(nonatomic,readonly) BOOL          downLimitEnabled;
@property(nonatomic,readonly) int           upLimitRate;
@property(nonatomic,readonly) int           downLimitRate;

@property(nonatomic,readonly) BOOL          seedRatioLimitEnabled;
@property(nonatomic,readonly) float         seedRatioLimit;

@property(nonatomic,readonly) BOOL          portForfardingEnabled;
@property(nonatomic,readonly) BOOL          portRandomAtStartEnabled;
@property(nonatomic,readonly) int           port;

@property(nonatomic,readonly) BOOL          UTPEnabled;
@property(nonatomic,readonly) BOOL          PEXEnabled;
@property(nonatomic,readonly) BOOL          LPDEnabled;
@property(nonatomic,readonly) BOOL          DHTEnabled;

@property(nonatomic,readonly) int           globalPeerLimit;
@property(nonatomic,readonly) int           torrentPeerLimit;

@property(nonatomic,readonly) NSString*     encryption;

@property(nonatomic,readonly) int           seedIdleLimit;
@property(nonatomic,readonly) BOOL          seedIdleLimitEnabled;

@property(nonatomic,readonly) BOOL          altLimitEnabled;
@property(nonatomic,readonly) int           altDownloadRateLimit;
@property(nonatomic,readonly) int           altUploadRateLimit;

@property(nonatomic,readonly) BOOL          addPartToUnfinishedFilesEnabled;

@end

@implementation TRSessionInfo

+ (TRSessionInfo *)sessionInfoFromJSON:(NSDictionary *)dict
{
    return [[TRSessionInfo alloc] initSessionInfoFromJSON:dict];
}


- (instancetype)initSessionInfoFromJSON:(NSDictionary*)dict
{
    self = [super init];
    
    if( !self )
        return self;
    
    _transmissionVersion = dict[TR_ARG_SESSION_VERSION];
    _rpcVersion = [NSString stringWithFormat:@"%@.%@", dict[TR_ARG_SESSION_RPCVER], dict[TR_ARG_SESSION_RPCVERMIN]];
    
    _downloadDir = dict[TR_ARG_SESSION_DOWNLOADDIR];
    _startDownloadingOnAdd = [(NSNumber*)dict[TR_ARG_SESSION_STARTONADD] boolValue];
    _upLimitEnabled = [(NSNumber*)dict[TR_ARG_SESSION_LIMITUPRATEENABLED] boolValue];
    _downLimitEnabled = [(NSNumber*)dict[TR_ARG_SESSION_LIMITDOWNRATEENABLED] boolValue];
    _upLimitRate = [(NSNumber*)dict[TR_ARG_SESSION_LIMITUPRATE] intValue];
    _downLimitRate = [(NSNumber*)dict[TR_ARG_SESSION_LIMITDOWNRATE] intValue];
    
    _seedRatioLimitEnabled = [(NSNumber*)dict[TR_ARG_SESSION_SEEDRATIOLIMITENABLED] boolValue];
    _seedRatioLimit = [(NSNumber*)dict[TR_ARG_SESSION_SEEDRATIOLIMIT] floatValue];
    
    _portForfardingEnabled = [(NSNumber*)dict[TR_ARG_SESSION_PORTFORWARDENABLED] boolValue];
    _portRandomAtStartEnabled = [(NSNumber*)dict[TR_ARG_SESSION_PORTRANDOMONSTART] boolValue];
    _port = [(NSNumber*)dict[TR_ARG_SESSION_PORT] intValue];
    
    _UTPEnabled = [(NSNumber*)dict[TR_ARG_SESSION_UTPENABLED] boolValue];
    _PEXEnabled = [(NSNumber*)dict[TR_ARG_SESSION_PEXENABLED] boolValue];
    _LPDEnabled = [(NSNumber*)dict[TR_ARG_SESSION_LPDENABLED] boolValue];
    _DHTEnabled = [(NSNumber*)dict[TR_ARG_SESSION_DHTENABLED] boolValue];
    
    _globalPeerLimit = [(NSNumber*)dict[TR_ARG_SESSION_PEERLIMITTOTAL] intValue];
    _torrentPeerLimit = [(NSNumber*)dict[TR_ARG_SESSION_PEERLIMITPERTORRENT] intValue];
    
    _encryption = dict[TR_ARG_SESSION_ENRYPTION];
    _seedIdleLimit = [(NSNumber*)dict[TR_ARG_SESSION_IDLESEEDLIMIT] intValue];
    _seedIdleLimitEnabled = [(NSNumber*)dict[TR_ARG_SESSION_IDLELIMITENABLED] boolValue];
    
    _altLimitEnabled = [(NSNumber*)dict[TR_ARG_SESSION_ALTLIMITRATEENABLED] boolValue];
    _altDownloadRateLimit = [(NSNumber*)dict[TR_ARG_SESSION_ALTLIMIDOWNRATE] intValue];
    _altUploadRateLimit = [(NSNumber*)dict[TR_ARG_SESSION_ALTLIMITUPRATE] intValue];
    
    _addPartToUnfinishedFilesEnabled = [(NSNumber*)dict[TR_ARG_SESSION_RENAMEPARTIAL] boolValue];
    
    return self;
}

@end
