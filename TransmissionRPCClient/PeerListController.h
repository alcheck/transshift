//
//  PeerListController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableController.h"
#import "TRPeerInfo.h"

#define CONTROLLER_ID_PEERLIST     @"peerListController"

@protocol PeerListControllerDelegate <NSObject>

@optional - (void)peerListNeedUpdatePeersForTorrentId:(int)torrentId;

@end

@interface PeerListController : CommonTableController

@property(weak) id<PeerListControllerDelegate> delegate;

- (void)updateWithPeers:(NSArray *)peers andPeerStat:(TRPeerStat *)peerStat;

@property(nonatomic) int            torrentId;

@end
