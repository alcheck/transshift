//
//  FileListController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableController.h"

#define CONTROLLER_ID_FILELIST  @"fileListController"

@class FSDirectory;

@protocol FileListControllerDelegate <NSObject>

@optional - (void)fileListControllerNeedUpdateFilesForTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerStopDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerResumeDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerSetPriority:(int)priority forFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerRenameTorrent:(int)torrentId oldItemName:(NSString *)oldItemName newItemName:(NSString *)newItemName;

@end

@interface FileListController : CommonTableController

@property(weak) id<FileListControllerDelegate> delegate;

@property(nonatomic) int            torrentId;
@property(nonatomic) FSDirectory    *fsDir;

/// Update current FSDicectroy with array of TRFileStats
@property(nonatomic) NSArray        *fileStats;

/// Flag indicates if this torrent if fully loaded and not needed be updated more
@property(nonatomic, readonly) BOOL isFullyLoaded;

@property(nonatomic) BOOL           selectOnly;

- (void)stoppedToDownloadFilesWithIndexes:(NSArray *)indexes;
- (void)resumedToDownloadFilesWithIndexes:(NSArray *)indexes;

@end
