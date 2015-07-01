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

@property(nonatomic,readonly) NSString*  name;
@property(nonatomic,readonly) NSString*  fileName;
@property(nonatomic,readonly) long long  bytesComplited;
@property(nonatomic,readonly) NSString*  bytesComplitedString;
@property(nonatomic,readonly) long long  length;
@property(nonatomic,readonly) NSString*  lengthString;
@property(nonatomic,readonly) BOOL       wanted;
@property(nonatomic,readonly) int        priority;               /* TR_FILEINFO_PRIORITY */
@property(nonatomic,readonly) NSString*  priorityString;
@property(nonatomic,readonly) float      downloadProgress;       /* 0 .. 1 */
@property(nonatomic,readonly) NSString*  downloadProgressString;
@property(nonatomic,readonly) int        folderLevel;
@property(nonatomic,readonly) NSString*  parentFolderName;       

@end
