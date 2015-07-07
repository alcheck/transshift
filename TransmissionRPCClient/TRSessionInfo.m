//
//  TRSessionInfo.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRSessionInfo.h"

#define ENCRYPTION_ID_REQUIRED   @"required"
#define ENCRYPTION_ID_PREFFERED  @"preffered"
#define ENCRYPTION_ID_TOLERATED  @"tolerated"

@interface TRSessionInfo()

@end

@implementation TRSessionInfo

{
    int _encryptionId;
}

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
    _rpcVersion = [NSString stringWithFormat:@"%@(min supported %@)", dict[TR_ARG_SESSION_RPCVER], dict[TR_ARG_SESSION_RPCVERMIN]];
    
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

// return JSON for RPC session-set
- (NSDictionary *)jsonForRPC
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    dict[TR_ARG_SESSION_STARTONADD] = @(_startDownloadingOnAdd);
    dict[TR_ARG_SESSION_RENAMEPARTIAL] = @(_addPartToUnfinishedFilesEnabled);
    
    dict[TR_ARG_SESSION_LIMITUPRATEENABLED] = @(_upLimitEnabled);
    if( _upLimitEnabled )
        dict[TR_ARG_SESSION_LIMITUPRATE] = @(_upLimitRate);
    
    dict[TR_ARG_SESSION_LIMITDOWNRATEENABLED] = @(_downLimitEnabled);
    if( _downLimitEnabled )
        dict[TR_ARG_SESSION_LIMITDOWNRATE] = @(_downLimitRate);
    
    dict[TR_ARG_SESSION_SEEDRATIOLIMITENABLED] = @(_seedIdleLimitEnabled);
    
    if( _seedIdleLimitEnabled )
        dict[TR_ARG_SESSION_SEEDRATIOLIMIT] = @(_seedRatioLimit);
    
    dict[TR_ARG_SESSION_PORTFORWARDENABLED] = @(_portForfardingEnabled);
    dict[TR_ARG_SESSION_PORTRANDOMONSTART] = @(_portRandomAtStartEnabled);
    dict[TR_ARG_SESSION_PORT] = @(_port);
    
    dict[TR_ARG_SESSION_UTPENABLED] = @(_UTPEnabled);
    dict[TR_ARG_SESSION_PEXENABLED] = @(_PEXEnabled);
    dict[TR_ARG_SESSION_LPDENABLED] = @(_LPDEnabled);
    dict[TR_ARG_SESSION_DHTENABLED] = @(_DHTEnabled);
    
    dict[TR_ARG_SESSION_PEERLIMITTOTAL] = @(_globalPeerLimit);
    dict[TR_ARG_SESSION_PEERLIMITPERTORRENT] = @(_torrentPeerLimit);
  
    dict[TR_ARG_SESSION_ENRYPTION] = _encryption;
    
    dict[TR_ARG_SESSION_IDLELIMITENABLED] = @(_seedIdleLimitEnabled);
    
    if( _seedIdleLimitEnabled )
        dict[TR_ARG_SESSION_IDLESEEDLIMIT] = @(_seedIdleLimit);
    
    dict[TR_ARG_SESSION_ALTLIMITRATEENABLED] = @(_altLimitEnabled);
    if( _altLimitEnabled )
    {
        dict[TR_ARG_SESSION_ALTLIMIDOWNRATE] = @(_altDownloadRateLimit);
        dict[TR_ARG_SESSION_ALTLIMITUPRATE] = @(_altUploadRateLimit);
    }
   
    return dict;
}

- (int)encryptionId
{
    _encryptionId = [_encryption isEqualToString:ENCRYPTION_ID_REQUIRED] ? 0 : ( [_encryption isEqualToString:ENCRYPTION_ID_PREFFERED] ? 1 : 2 );
    return _encryptionId;
}

- (void)setEncryptionId:(int)encryptionId
{
    _encryptionId = encryptionId;
    _encryption = _encryptionId == 0 ? ENCRYPTION_ID_REQUIRED : ( _encryptionId == 1 ? ENCRYPTION_ID_PREFFERED : ENCRYPTION_ID_TOLERATED );
}

@end
