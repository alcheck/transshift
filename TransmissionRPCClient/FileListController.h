//
//  FileListController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_FILELIST  @"fileListController"

@protocol FileListControllerDelegate <NSObject>

@optional - (void)fileListControllerNeedUpdateFilesForTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerStopDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerResumeDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
@optional - (void)fileListControllerSetPriority:(int)priority forFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;

@end

@interface FileListController : UITableViewController

@property(weak) id<FileListControllerDelegate> delegate;

@property(nonatomic) NSArray*   fileInfos;
@property(nonatomic) int        torrentId;

@property(nonatomic) BOOL       torrentIsFinished;

@end
