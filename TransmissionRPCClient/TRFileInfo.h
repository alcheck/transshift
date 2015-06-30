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

@end
