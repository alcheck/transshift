//
//  StatusListController.h
//  TransmissionRPCClient
//
//  UI Controller for torrent statuses
//  All, Downloading, Seeding, Stopped

#import <UIKit/UIKit.h>
#import "RPCServerConfig.h"

#define CONTROLLER_ID_TORRENTSSTATUSLIST    @"torrentsStatusListContoller"
#define CELL_ID_TORRENTSTATUS               @"torrentStatusCell"

@interface StatusListController : UITableViewController

@property(nonatomic) RPCServerConfig *config;

- (void)stopUpdating;

@end
