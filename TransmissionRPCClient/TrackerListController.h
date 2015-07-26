//
//  TrackerListController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "CommonTableController.h"
#import "GlobalConsts.h"
#import "TrackerStat.h"

#define CONTROLLER_ID_TRACKERLIST   @"trackerListController"

@protocol TrackerListControllerDelegate <NSObject>

@optional - (void)trackerListNeedUpdateDataForTorrentWithId:(int)torrentId;
@optional - (void)trackerListRemoveTracker:(int)trackerId forTorrent:(int)torrentId;

@end


@interface TrackerListController : CommonTableController

@property(weak) id<TrackerListControllerDelegate> delegate;
@property(nonatomic) NSArray* trackers;
@property(nonatomic) int torrentId;

@end
