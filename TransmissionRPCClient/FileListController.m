//
//  FileListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "FileListController.h"
//#import "FileListCell.h"
#import "FSDirectory.h"
#import "FileListFSCell.h"
#import "TRFileInfo.h"
#import "NSObject+DataObject.h"

#define ICON_FILE             @"iconFile"
#define ICON_FOLDER_OPENED    @"iconFolderOpened"
#define ICON_FOLDER_CLOSED    @"iconFolderClosed"

@interface FileListController ()
@end

@implementation FileListController

{
    UIImage *_iconImgFile;
    UIImage *_iconImgFolderOpened;
    UIImage *_iconImgFolderClosed;
    
    FSDirectory *_fsDir;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // preload images
    _iconImgFile = [[UIImage imageNamed:ICON_FILE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconImgFolderOpened = [[UIImage imageNamed:ICON_FOLDER_OPENED] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconImgFolderClosed = [[UIImage imageNamed:ICON_FOLDER_CLOSED] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
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

// update file infos
- (void)setFileInfos:(NSArray *)fileInfos
{
    //_fileInfos = fileInfos;
    // create new file system directory
    // and add all items

    BOOL needToSort = NO;
    if( !_fsDir )
    {
        _fsDir = [FSDirectory directory];
        needToSort = YES;
    }
    
    for( int i = 0; i < fileInfos.count; i++ )
    {
        TRFileInfo *fileInfo = fileInfos[i];
        FSItem *item = [_fsDir addFilePath:fileInfo.name withIndex:i];
        item.info = fileInfo;
    }
    
    if( needToSort )
        [_fsDir sort];
    
    [_fsDir setNeedToRecalcStats];
    
    [self.tableView reloadData];
}

- (void)toggleFolderDownloading:(UIGestureRecognizer*)sender
{
    sender.view.userInteractionEnabled = NO;
        
    FSItem *item = sender.dataObject;
    NSArray *fileIndexes = item.fileIndexes;
    
    BOOL wanted = !item.isAllFilesWanted;
    
    if( _delegate && wanted &&
       [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerResumeDownloadingFilesWithIndexes:fileIndexes
                                                      forTorrentWithId:_torrentId];
    }
    else if( _delegate && !wanted &&
            [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerStopDownloadingFilesWithIndexes:fileIndexes
                                                    forTorrentWithId:_torrentId];
    }
    
    [self askDelegateForDataUpdate];
}


- (void)toggleFileDownloading:(UIGestureRecognizer*)sender
{
    FSItem* item = sender.dataObject;
    BOOL wanted = !item.info.wanted;
    
    //sender.enabled = NO;
    sender.view.userInteractionEnabled = NO;
    
    //NSLog(@"Switch is toggled, %@", info.name);
    if( _delegate && wanted &&
       [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerResumeDownloadingFilesWithIndexes:@[@(item.index)]
                                                      forTorrentWithId:_torrentId];
    }
    else if( _delegate && !wanted &&
            [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerStopDownloadingFilesWithIndexes:@[@(item.index)]
                                                    forTorrentWithId:_torrentId];
    }
    
    [self askDelegateForDataUpdate];
}

- (void)prioritySegmentToggled:(UISegmentedControl*)sender
{
    sender.enabled = NO;
    
    int priority = (int)sender.selectedSegmentIndex - 1;
    
    if( _delegate && [_delegate respondsToSelector:@selector(fileListControllerSetPriority:forFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerSetPriority:priority forFilesWithIndexes:@[sender.dataObject] forTorrentWithId:_torrentId];
    }
    
    [self askDelegateForDataUpdate];
}

// toggle collapse flag
- (void)folderTapped:(UITapGestureRecognizer*)sender
{
    FSItem *item = sender.dataObject;
    item.collapsed = !item.collapsed;
    
    //NSLog(@"Folder %@ has all files wanted: %@", item.name, item.isAllFilesWanted ? @"YES" : @"NO");
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fsDir ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Files & Folders";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fsDir.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListFSCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FILELISTFSCELL forIndexPath:indexPath];
    FSItem *item = [_fsDir itemAtIndex:(int)indexPath.row];
   
    //cell.leftLabel.bounds = r;
    cell.nameLabel.text = item.name;
    cell.iconImg.image = item.isFile ? _iconImgFile : (  item.isCollapsed ? _iconImgFolderClosed : _iconImgFolderOpened );
    
    NSArray *arr = cell.leftLabel.constraints;
    [cell.leftLabel removeConstraints:arr];
    
    // make indentation
    float leftIdent = FILELISTFSCELL_LEFTLABEL_WIDTH + ( (item.level - 1) * FILELISTFSCELL_LEFTLABEL_LEVEL_INDENTATION );
    NSLayoutConstraint *widthConstraint = [arr firstObject];
    widthConstraint.constant = leftIdent;
    [cell.leftLabel addConstraints:arr];
    
    cell.iconImg.userInteractionEnabled = NO;
    cell.iconImg.tintColor = cell.tintColor;            // default (blue) tintColor
    cell.leftLabel.userInteractionEnabled = NO;
    cell.prioritySegment.hidden = YES;
    cell.nameLabel.textColor = [UIColor blackColor];
    
    if( item.isFile )
    {
        cell.detailLabel.text = [NSString stringWithFormat:@"%@ of %@, %@ downloaded",
                                 item.info.bytesComplitedString,
                                 item.info.lengthString,
                                 item.info.downloadProgressString];
        
        if( item.info.downloadProgress < 1.0f )
        {
            // configure priority segment control
            [cell.prioritySegment addTarget:self action:@selector(prioritySegmentToggled:) forControlEvents:UIControlEventValueChanged];
            cell.prioritySegment.dataObject = @(item.index);
            cell.prioritySegment.selectedSegmentIndex = item.info.priority + 1;
            cell.prioritySegment.enabled = YES;
            cell.prioritySegment.hidden = NO;

            // configure left checkBox control
            cell.leftLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFileDownloading:)];
            tapRecognizer.dataObject = item;
            [cell.leftLabel addGestureRecognizer:tapRecognizer];
            
            if( !item.info.wanted )
            {
                cell.prioritySegment.hidden = YES;
                cell.iconImg.tintColor = [UIColor grayColor];
                cell.nameLabel.textColor = [UIColor grayColor];
            }
            
            cell.leftLabel.text = item.info.wanted ? @"☑︎" : @"◻︎";
        }
        else
        {
            cell.leftLabel.text = @" ";
        }
    }
    else // it is folder
    {
        cell.detailLabel.text = [NSString stringWithFormat:@"%i files, %@ of %@, %@ downloaded",
                                 item.filesCount,
                                 item.folderDownloadedString,
                                 item.folderSizeString,
                                 item.folderDownloadProgressString];
        
        if( item.folderDownloadProgress < 1.0 )
        {
            // get info for files within folder
            cell.leftLabel.text = item.isAllFilesWanted ? @"☑︎" : @"◻︎";
            cell.nameLabel.textColor = item.isAllFilesWanted ? [UIColor blackColor] : [UIColor grayColor];
            cell.iconImg.tintColor = item.isAllFilesWanted ? cell.tintColor : [UIColor grayColor];
            
            // add handler for checking wanted/unwanted files
            cell.leftLabel.userInteractionEnabled = YES;
            
             // add recognizer for unwanted files
             UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFolderDownloading:)];
             recognizer.dataObject = item;
             [cell.leftLabel addGestureRecognizer:recognizer];
        }
        else
        {
            cell.leftLabel.text = @" ";
        }
        
        
        // add handler to folder icon for collapsing/uncollapsing folder
        cell.iconImg.userInteractionEnabled = YES;
        cell.nameLabel.userInteractionEnabled = YES;
        cell.detailLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapRecIcon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(folderTapped:)];
        UITapGestureRecognizer *tapRecLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(folderTapped:)];
        UITapGestureRecognizer *tapRecDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(folderTapped:)];
        
        tapRecDetail.dataObject = item;
        tapRecIcon.dataObject = item;
        tapRecLabel.dataObject = item;
        
        [cell.iconImg addGestureRecognizer:tapRecIcon];
        [cell.nameLabel addGestureRecognizer:tapRecLabel];
        [cell.detailLabel addGestureRecognizer:tapRecDetail];
    }
    
    return cell;
}

@end
