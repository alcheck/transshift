//
//  RPCServerConfigController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPCServerConfig.h"

#define CONTROLLER_ID_RPCSERVERCONFIG @"RPCServerConfig"

@interface RPCServerConfigController : UITableViewController

@property(nonatomic) RPCServerConfig *config;

@end
