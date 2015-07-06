//
//  StatusListController.h
//  TransmissionRPCClient
//
//  UI Controller for torrent statuses
//  All, Downloading, Seeding, Stopped

#import <UIKit/UIKit.h>
#import "RPCServerConfig.h"
#import "CommonTableController.h"
#import "GlobalConsts.h"

#define CONTROLLER_ID_TORRENTSSTATUSLIST    @"torrentsStatusListContoller"

@interface StatusListController : CommonTableController

@property(nonatomic) RPCServerConfig *config;

- (void)stopUpdating;

@end
