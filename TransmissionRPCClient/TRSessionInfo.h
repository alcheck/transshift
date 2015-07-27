//
//  TRSessionInfo.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCConfigValues.h"

@interface TRSessionInfo : NSObject

+ (TRSessionInfo*)sessionInfoFromJSON:(NSDictionary*)dict;


@property(nonatomic) NSString*     transmissionVersion;
@property(nonatomic) NSString*     rpcVersion;
@property(nonatomic) NSString*     downloadDir;

@property(nonatomic) BOOL          startDownloadingOnAdd;

@property(nonatomic) BOOL          upLimitEnabled;
@property(nonatomic) BOOL          downLimitEnabled;
@property(nonatomic) int           upLimitRate;
@property(nonatomic) int           downLimitRate;

@property(nonatomic) BOOL          seedRatioLimitEnabled;
@property(nonatomic) float         seedRatioLimit;

@property(nonatomic) BOOL          portForfardingEnabled;
@property(nonatomic) BOOL          portRandomAtStartEnabled;
@property(nonatomic) int           port;

@property(nonatomic) BOOL          UTPEnabled;
@property(nonatomic) BOOL          PEXEnabled;
@property(nonatomic) BOOL          LPDEnabled;
@property(nonatomic) BOOL          DHTEnabled;

@property(nonatomic) int           globalPeerLimit;
@property(nonatomic) int           torrentPeerLimit;

@property(nonatomic) NSString*     encryption;
@property(nonatomic) int           encryptionId;               // 0 - required, 1 - preffered, 2 - tolerated

@property(nonatomic) int           seedIdleLimit;
@property(nonatomic) BOOL          seedIdleLimitEnabled;

@property(nonatomic) BOOL          altLimitEnabled;
@property(nonatomic) int           altDownloadRateLimit;
@property(nonatomic) int           altUploadRateLimit;
@property(nonatomic) BOOL          altLimitTimeEnabled;
@property(nonatomic) int           altLimitTimeBegin;
@property(nonatomic) int           altLimitTimeEnd;
@property(nonatomic) int           altLimitDay;

@property(nonatomic) BOOL          addPartToUnfinishedFilesEnabled;

// get json from config
@property(nonatomic,readonly) NSDictionary* jsonForRPC;

@end
