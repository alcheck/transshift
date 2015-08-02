//
//  TRPeerInfo.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCConfigValues.h"

@interface TRPeerStat : NSObject

@property(nonatomic,readonly) NSString *fromChache;
@property(nonatomic,readonly) NSString *fromDht;
@property(nonatomic,readonly) NSString *fromIncoming;
@property(nonatomic,readonly) NSString *fromLpd;
@property(nonatomic,readonly) NSString *fromPex;
@property(nonatomic,readonly) NSString *fromTracker;

+ (TRPeerStat *)peerStatWithJSONData:(NSDictionary*)dict;

@end

@interface TRPeerInfo : NSObject

@property(nonatomic,readonly) NSString* ipAddress;
@property(nonatomic,readonly) int       port;
@property(nonatomic,readonly) NSString* rateToClientString;     /* download rate */
@property(nonatomic,readonly) long long rateToClient;
@property(nonatomic,readonly) NSString* rateToPeerString;       /* upload rate */
@property(nonatomic,readonly) long long rateToPeer;
@property(nonatomic,readonly) NSString* flagString;
@property(nonatomic,readonly) NSString* clientName;
@property(nonatomic,readonly) float     progress;
@property(nonatomic,readonly) NSString* progressString;
@property(nonatomic,readonly) BOOL      isEncrypted;
@property(nonatomic,readonly) BOOL      isUTP;

+ (TRPeerInfo *)peerInfoWithJSONData:(NSDictionary*)dict;

@end
