//
//  TorrentInfoController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRInfo.h"

#define CONTROLLER_ID_TORRENTINFO   @"torrentInfoController"

@protocol TorrentInfoControllerDelegate <NSObject>

@optional - (void)resumeTorrentWithId:(int)torrentId;
@optional - (void)stopTorrentWithId:(int)torrentId;
@optional - (void)deleteTorrentWithId:(int)torrentId deleteWithData:(BOOL)deleteWithData;
@optional - (void)reannounceTorrentWithId:(int)torrentId;
@optional - (void)verifyTorrentWithId:(int)torrentId;
@optional - (void)updateTorrentInfoWithId:(int)torrentId;

@end

@interface TorrentInfoController : UITableViewController

// holds torrent id
@property(nonatomic) int torrentId;

// delegate
@property(weak) id<TorrentInfoControllerDelegate> delegate;

// update data with given TRInfo
// this method should be used outside (by delegate) on update cycle
- (void)updateData:(TRInfo*)trInfo;
- (void)showErrorMessage:(NSString*)errorMessage;

@end
