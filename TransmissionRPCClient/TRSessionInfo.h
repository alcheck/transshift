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

@end
