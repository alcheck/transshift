//
//  RPCServerConfigDB.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPCServerConfigDB : NSObject

+ (RPCServerConfigDB*)sharedDB;

@property(nonatomic,readonly) NSMutableArray *db;
- (void)loadDB;
- (void)saveDB;

@end
