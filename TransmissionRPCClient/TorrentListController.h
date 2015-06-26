//
//  TorrentListController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_TORRENTLIST   @"torrentListController"

@interface TorrentListController : UITableViewController

@property(nonatomic) NSString *backgroundTitle;

@end
