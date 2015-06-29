//
//  ChooseServerToAddTorrentController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_CHOOSESERVER  @"chooseServerToAddTorrentController"

@class RPCServerConfig;

@interface ChooseServerToAddTorrentController : UIViewController

@property(nonatomic,readonly) RPCServerConfig *selectedRPCConfig;

@end
