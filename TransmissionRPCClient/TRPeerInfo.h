//
//  TRPeerInfo.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCConfigValues.h"

@interface TRPeerInfo : NSObject

@property(nonatomic,readonly) NSString* ipAddress;
@property(nonatomic,readonly) int       port;
@property(nonatomic,readonly) NSString* rateToClientString;
@property(nonatomic,readonly) NSString* rateToPeerString;
@property(nonatomic,readonly) NSString* flagString;
@property(nonatomic,readonly) NSString* clientName;
@property(nonatomic,readonly) float     progress;
@property(nonatomic,readonly) NSString* progressString;
@property(nonatomic,readonly) BOOL      isEncrypted;

+ (TRPeerInfo*)peerInfoWithJSONData:(NSDictionary*)dict;

@end
