//
//  ChooseServerToAddTorrentController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConsts.h"
#import "CommonTableController.h"
#import "FSDirectory.h"

#define CONTROLLER_ID_CHOOSESERVER  @"chooseServerToAddController"
#define CELL_ID_FILESTODOWNLOAD     @"filesToDownloadCell"
#define CELL_ID_TRACKERLIST         @"trackerListCell"

@class RPCServerConfig;

@interface ChooseServerToAddTorrentController : CommonTableController

@property(nonatomic,readonly) RPCServerConfig *rpcConfig;   // using only for returning config
@property(nonatomic) int                      bandwidthPriority;
@property(nonatomic) BOOL                     startImmidiately;
@property(nonatomic) FSDirectory              *files;
@property(nonatomic) NSArray                  *announceList;
@property(nonatomic) BOOL                     isMagnet;     // set Yes if title icon shoud be magnet

- (void)setTorrentTitle:(NSString *)title andTorrentSize:(NSString *)size;

@end
