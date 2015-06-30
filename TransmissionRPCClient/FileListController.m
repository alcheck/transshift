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
    
    cell.filenameLabel.text = info.fileName;
    cell.indendLabel.text = @"";
    cell.wantedSwitch.on = info.wanted;
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ of %@, %@ downloaded", info.bytesComplitedString, info.lengthString, info.downloadProgressString];
    
    cell.prioritySegment.selectedSegmentIndex = info.priority + 1;
    
    return cell;
}

@end
