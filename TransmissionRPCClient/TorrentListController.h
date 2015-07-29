//
//  TorrentListController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableController.h"
#import "GlobalConsts.h"
#import "StatusCategory.h"

#define CONTROLLER_ID_TORRENTLIST   @"torrentListController"

// delegate protocol
@protocol TorrentListControllerDelegate <NSObject>

// ask delegate to show detail info for torrent with given id
@optional - (void)showDetailedInfoForTorrentWithId:(int)torrentId;

// ask delegate to delete torrent with given id
@optional - (void)torrentListRemoveTorrentWithId:(int)torrentId removeWithData:(BOOL)removeWithData;

@optional - (void)torrentListStopTorrentWithId:(int)torrentId;
@optional - (void)torrentListResumeTorrentWithId:(int)torrentId;
@optional - (void)torrentListStartAllTorrents;
@optional - (void)torrentListStopAllTorrents;

@end


@interface TorrentListController : CommonTableController <UISplitViewControllerDelegate>

@property(weak) id<TorrentListControllerDelegate> delegate;

@property(nonatomic) NSString *popoverButtonTitle;

// hold current torrents (will dispose later)
//@property(nonatomic) TRInfos *torrents;

// this is main method for updating data
@property(nonatomic) StatusCategory *items;

@end
