//
//  SessionConfigController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "CommonTableController.h"
#import "GlobalConsts.h"
#import "TRSessionInfo.h"

#define CONTROLLER_ID_SESSIONCONFIG     @"sessionConfigController"

@protocol SessionConfigControllerDelegate <NSObject>

@optional - (void)sessionConfigControllerNeedUpdateData;
@optional - (void)sessionConfigControllerUpdateSession:(TRSessionInfo*)session;

@end

@interface SessionConfigController : CommonTableController

@property(weak,nonatomic) id<SessionConfigControllerDelegate> delegate;
@property(nonatomic) TRSessionInfo*  sessionInfo;
@property(nonatomic) BOOL portIsOpen;

- (BOOL)saveConfig;

@end
