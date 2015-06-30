//
//  TRFileInfo.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCConfigValues.h"

#define TR_FILEINFO_PRIORITY_LOW       -1
#define TR_FILEINFO_PRIORITY_NORMAL     0
#define TR_FILEINFO_PRIORITY_HIGH       1

@interface TRFileInfo : NSObject

+ (TRFileInfo*)fileInfoFromJSON:(NSDictionary*)dict;

@property(nonatomic) NSString*  name;
@property(nonatomic) NSString*  fileName;
@property(nonatomic) long long  bytesComplited;
@property(nonatomic) NSString*  bytesComplitedString;
@property(nonatomic) long long  length;
@property(nonatomic) NSString*  lengthString;
@property(nonatomic) BOOL       wanted;
@property(nonatomic) int        priority;               /* TR_FILEINFO_PRIORITY */
@property(nonatomic) NSString*  priorityString;
@property(nonatomic) float      downloadProgress;       /* 0 .. 1 */
@property(nonatomic) NSString*  downloadProgressString;

@end
