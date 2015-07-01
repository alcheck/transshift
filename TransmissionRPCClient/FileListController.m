//
//  FileListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "FileListController.h"
#import "FileListCell.h"
#import "TRFileInfo.h"
#import <objc/runtime.h>

// assosiative object
@interface NSObject(AssosiatedObject)
    @property(nonatomic) id dataObject;
@end

@implementation NSObject(AssosiatedObject)

@dynamic dataObject;

- (id)dataObject
{
    return objc_getAssociatedObject(self, @selector(dataObject));
}

- (void)setDataObject:(id)dataObject
{
    objc_setAssociatedObject(self, @selector(dataObject), dataObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface FileListController ()
@end

@implementation FileListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    
    [self.refreshControl addTarget:self action:@selector(askDelegateForDataUpdate) forControlEvents:UIControlEventValueChanged];
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem.title = @"Info";
}

- (void)askDelegateForDataUpdate
{
    [self.refreshControl endRefreshing];
    if( _delegate && [_delegate respondsToSelector:@selector(fileListControllerNeedUpdateFilesForTorrentWithId:)])
        [_delegate fileListControllerNeedUpdateFilesForTorrentWithId:_torrentId];
}


- (void)setFileInfos:(NSArray *)fileInfos
{
    _fileInfos = fileInfos;
    [self.tableView reloadData];
}

- (void)switchIsToggled:(UISwitch*)sender
{
    NSIndexPath* indexPath = sender.dataObject;
    BOOL switchState = sender.on;
    sender.enabled = NO;
    
    //NSLog(@"Switch is toggled, %@", info.name);
    if( _delegate && switchState &&
       [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerResumeDownloadingFilesWithIndexes:@[@(indexPath.row)]
                                                      forTorrentWithId:_torrentId];
    }
    else if( _delegate && !switchState &&
            [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerStopDownloadingFilesWithIndexes:@[@(indexPath.row)]
                                                    forTorrentWithId:_torrentId];
    }
}

- (void)prioritySegmentToggled:(UISegmentedControl*)sender
{
    NSIndexPath *path = sender.dataObject;
    sender.enabled = NO;
    
    int priority = sender.selectedSegmentIndex - 1;
    
    if( _delegate && [_delegate respondsToSelector:@selector(fileListControllerSetPriority:forFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerSetPriority:priority forFilesWithIndexes:@[@(path.row)] forTorrentWithId:_torrentId];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( _fileInfos && _fileInfos.count > 0 )
        return 1;

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Files & Folders";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fileInfos.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FILELIST forIndexPath:indexPath];
    
    TRFileInfo *info = _fileInfos[indexPath.row];
    
    cell.wantedSwitch.enabled = info.downloadProgress < 1.0f;
    cell.prioritySegment.enabled = info.downloadProgress < 1.0f;
    
    [cell.prioritySegment addTarget:self action:@selector(prioritySegmentToggled:) forControlEvents:UIControlEventValueChanged];
    [cell.wantedSwitch addTarget:self action:@selector(switchIsToggled:) forControlEvents:UIControlEventValueChanged];
    
    cell.wantedSwitch.dataObject = indexPath;
    cell.prioritySegment.dataObject = indexPath;
    
    cell.filenameLabel.text = info.fileName;
    cell.indendLabel.text = @"";
    cell.wantedSwitch.on = info.wanted;
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ of %@, %@ downloaded", info.bytesComplitedString, info.lengthString, info.downloadProgressString];
    
    cell.prioritySegment.selectedSegmentIndex = info.priority + 1;
    
    return cell;
}

@end
