//
//  TorrentInfoController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRInfo.h"
#import "CommonTableController.h"

#define CONTROLLER_ID_TORRENTINFO   @"torrentInfoController"

@protocol TorrentInfoControllerDelegate <NSObject>

@optional - (void)resumeTorrentWithId:(int)torrentId;
@optional - (void)stopTorrentWithId:(int)torrentId;
@optional - (void)deleteTorrentWithId:(int)torrentId deleteWithData:(BOOL)deleteWithData;
@optional - (void)reannounceTorrentWithId:(int)torrentId;
@optional - (void)verifyTorrentWithId:(int)torrentId;
@optional - (void)updateTorrentInfoWithId:(int)torrentId;

@optional - (void)showPeersForTorrentWithId:(int)torrentId;
@optional - (void)showFilesForTorrentWithId:(int)torrentId;
@optional - (void)showTrackersForTorrentWithId:(int)torrentId;
@optional - (void)applyTorrentSettings:(TRInfo*)info forTorrentWithId:(int)torrentId;

@optional - (void)getMagnetURLforTorrentWithId:(int)torrentId;
@optional - (void)renameTorrentWithId:(int)torrentId withNewName:(NSString *)newName andPath:(NSString *)path;
@optional - (void)showPiecesLegendForTorrentWithId:(int)torrentId piecesCount:(NSInteger)piecesCount pieceSize:(long long)pieceSize;

@end

@interface TorrentInfoController : CommonTableController

// holds torrent id
@property(nonatomic) int        torrentId;
@property(nonatomic) NSString   *magnetURL;

// delegate
@property(weak) id<TorrentInfoControllerDelegate> delegate;

// update data with given TRInfo
// this method should be used outside (by delegate) on update cycle
- (void)updateData:(TRInfo*)trInfo;

@end
