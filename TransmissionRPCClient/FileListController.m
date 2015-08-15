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
    
    //FSDirectory *_fsDir;
    BOOL     _isSelectOnly;
    FSItem  *_curItem;
    
    BOOL     _needUpdateFolders;
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
    
    self.navigationItem.leftBarButtonItem.title =  NSLocalizedString(@"Info", @"FileListController nav left button title");
}

- (void)askDelegateForDataUpdate
{
    [self.refreshControl endRefreshing];
    
    if( !_isFullyLoaded &&  _delegate && [_delegate respondsToSelector:@selector(fileListControllerNeedUpdateFilesForTorrentWithId:)])
        [_delegate fileListControllerNeedUpdateFilesForTorrentWithId:_torrentId];
}

- (void)stoppedToDownloadFilesWithIndexes:(NSArray *)indexes
{
    [self askDelegateForDataUpdate];
}

- (void)resumedToDownloadFilesWithIndexes:(NSArray *)indexes
{
    [self askDelegateForDataUpdate];
}

- (void)setFsDir:(FSDirectory *)fsDir
{
    _fsDir = fsDir;
    //_isSelectOnly = YES;
    _isFullyLoaded = fsDir.rootItem.downloadProgress >= 1.0f;
    
    [self.tableView reloadData];
}

- (void)updateFiles:(NSArray *)fileStats
{
    if( _curItem.isFile )
    {
        // update file item
        
        BOOL needUpdateCell = NO;
        BOOL justDownloaded = NO;
        
        TRFileStat *fileStat = fileStats[ _curItem.rpcIndex ];
        if( fileStat.bytesComplited != _curItem.bytesComplited )
        {
            needUpdateCell = YES;
            _curItem.bytesComplited = fileStat.bytesComplited;
            if( _curItem.downloadProgress >= 1.0f )
                justDownloaded = YES;
        }
        if ( fileStat.wanted != _curItem.wanted )
        {
            needUpdateCell = YES;
            _curItem.wanted = fileStat.wanted;
        }
        if( fileStat.priority != _curItem.priority )
        {
            needUpdateCell = YES;
            _curItem.priority = fileStat.priority;
        }
        
        if( needUpdateCell )
        {
            _needUpdateFolders = YES;
            
            NSUInteger row = [_fsDir indexForItem:_curItem];
            
            if( row != FSITEM_INDEXNOTFOUND )
            {
                // get cell
                FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                if( cell )
                {
                    [self updateFileCell:cell withFSItem:_curItem];
                    
                    if( !cell.checkBox.enabled && cell.checkBox.on == fileStat.wanted )
                    {
                        cell.checkBox.enabled = YES;
                    }
                    
                    if( !cell.prioritySegment.enabled && cell.prioritySegment.selectedSegmentIndex == (fileStat.priority + 1) )
                    {
                        cell.prioritySegment.enabled = YES;
                    }
                    
                    if( justDownloaded )
                    {
                        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
                            cell.iconImg.transform = CGAffineTransformMakeScale(1.2, 1.2);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.1 animations:^{
                                cell.iconImg.transform = CGAffineTransformIdentity;
                            }];
                        }];
                    }
                }
            }
        }
    }
    else
    {
        for( FSItem *i in _curItem.items )
        {
            _curItem = i;
            [self updateFiles:fileStats];
        }
    }
}

- (void)updateFolders
{
    if( _curItem.isFolder )
    {
        NSUInteger row = [_fsDir indexForItem:_curItem];
        
        if( row != FSITEM_INDEXNOTFOUND )
        {
            FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            if( cell )
            {
                [self updateFolderCell:cell withFSItem:_curItem];
                
                if( !cell.checkBox.enabled && cell.checkBox.on == _curItem.wanted )
                    cell.checkBox.enabled = YES;
            }
        }
        
        for( FSItem *i in _curItem.items )
        {
            _curItem = i;
            [self updateFolders];
        }
    }
}

// update file infos
- (void)setFileStats:(NSArray *)fileStats
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    
    _curItem = _fsDir.rootItem;
    _needUpdateFolders = NO;
    
    [self updateFiles:fileStats];
    
    if( _needUpdateFolders )
    {
        _curItem = _fsDir.rootItem;
        [_fsDir setNeedToRecalcStats];
        
        [self updateFolders];
        
        _isFullyLoaded = _fsDir.rootItem.downloadProgress >= 1.0f;
    }
}

- (void)toggleFolderDownloading:(CheckBox *)sender
{
    //sender.view.userInteractionEnabled = NO;
        
    FSItem *item = sender.dataObject;
    NSArray *fileIndexes = item.rpcFileIndexes;
    
    BOOL wanted = !item.wanted;
    
    if( _isSelectOnly )
    {
        item.wanted = wanted;
        [self.tableView reloadData];
        return;
    }
    
    //item.wanted = wanted;
    NSUInteger idx = [_fsDir indexForItem:item];
    if( idx != FSITEM_INDEXNOTFOUND )
    {
        FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        if( cell )
        {
            [cell.checkBox setOn:wanted animated:YES];
            cell.checkBox.enabled = NO;
        }
    }
    
    [self updateFilesForFolderItem:item wanted:wanted];
    
    [_fsDir setNeedToRecalcStats];
    _curItem = _fsDir.rootItem;
    [self updateFolders];
    
    
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
    //[self askDelegateForDataUpdate];
}

- (void)updateFilesForFolderItem:(FSItem *)item wanted:(BOOL)wanted
{
    for( FSItem *i in item.items )
    {
        NSUInteger idx = [_fsDir indexForItem:i];
        if( idx != FSITEM_INDEXNOTFOUND )
        {
            FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            if( cell )
            {
                [cell.checkBox setOn:wanted animated:YES];
                cell.checkBox.enabled = NO;
            }
        }
        if( i.isFolder )
        {
            [self updateFilesForFolderItem:i wanted:wanted];
        }
    }
}

- (void)toggleFileDownloading:(CheckBox *)sender
{
    FSItem* item = sender.dataObject;
    BOOL wanted = !item.wanted;
    
    //item.wanted = wanted;
    
    if( _isSelectOnly )
    {
        item.wanted = wanted;
        [self.tableView reloadData];
        return;
    }
    
    NSUInteger idx = [_fsDir indexForItem:item];
    if( idx != FSITEM_INDEXNOTFOUND )
    {
        FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        if( cell )
        {
            [cell.checkBox setOn:wanted animated:YES];
            cell.checkBox.enabled = NO;
        }
    }
    
    [_fsDir setNeedToRecalcStats];
    _curItem = _fsDir.rootItem;
    [self updateFolders];
    
  
    if( _delegate && wanted && [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerResumeDownloadingFilesWithIndexes:@[@(item.rpcIndex)]
                                                      forTorrentWithId:_torrentId];
    }
    else if( _delegate && !wanted &&
            [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerStopDownloadingFilesWithIndexes:@[@(item.rpcIndex)]
                                                    forTorrentWithId:_torrentId];
    }
    
    //[self askDelegateForDataUpdate];
}

- (void)prioritySegmentToggled:(UISegmentedControl*)sender
{
    sender.enabled = NO;
    
    int priority = (int)sender.selectedSegmentIndex - 1;
    
    if( _delegate && [_delegate respondsToSelector:@selector(fileListControllerSetPriority:forFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerSetPriority:priority forFilesWithIndexes:@[sender.dataObject] forTorrentWithId:_torrentId];
    }
    //[self askDelegateForDataUpdate];
}

// toggle collapse flag
- (void)folderTapped:(UITapGestureRecognizer*)sender
{
    FSItem *item = sender.dataObject;
    
    item.collapsed = !item.collapsed;
    int itemIndex = [_fsDir indexForItem:item];
    NSArray *indexPaths = [_fsDir childIndexesForItem:item startRow:itemIndex section:0];
    
    [self.tableView beginUpdates];
        
    if( item.collapsed )
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    else
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        
    [self.tableView endUpdates];
    
    FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:itemIndex inSection:0]];
    if( cell )
    {
        cell.iconImg.image = item.isCollapsed ? _iconImgFolderClosed : _iconImgFolderOpened;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fsDir ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString( @"Files & Folders", @"");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fsDir.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListFSCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FILELISTFSCELL forIndexPath:indexPath];
    
    FSItem *item = [_fsDir itemAtIndex:(int)indexPath.row];

    if( item.isFolder )
        [self updateFolderCell:cell withFSItem:item];
    else
        [self updateFileCell:cell withFSItem:item];
    
    return cell;
}

- (void)updateFileCell:(FileListFSCell *)cell withFSItem:(FSItem *)item
{
    cell.nameLabel.text = item.name;
    cell.iconImg.image =  _iconImgFile;
    
    // make indentation
    float leftIdent = ( (item.level - 1) * FILELISTFSCELL_LEFTLABEL_LEVEL_INDENTATION ) + 8;
    float checkBoxWidth = 33;
    
    if( _isFullyLoaded )
    {
        cell.checkBox.hidden = YES;
        checkBoxWidth = 0;
    }
    else
        cell.checkBox.hidden = NO;
    
    cell.checkBoxLeadConstraint.constant = leftIdent;
    cell.checkBoxWidthConstraint.constant = checkBoxWidth;
    
    cell.iconImg.tintColor = cell.tintColor;            // default (blue) tintColor
    cell.prioritySegment.hidden = YES;                  // by default folders don't have priority segment
    cell.nameLabel.textColor = [UIColor blackColor];    // by default file/folder names are black
    
    cell.nameLabelTrailConstraint.priority = 751;
    cell.nameLabelTrailToSegmentConstraint.priority = 750;
    cell.touchView.userInteractionEnabled = NO;
    cell.prioritySegment.dataObject = item;
    
    if (_isSelectOnly)
    {
        cell.detailLabel.text = item.lengthString;
    }
    else
    {
        cell.detailLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%@ of %@, %@ downloaded", @"FileList cell file info"),
                                     item.bytesComplitedString,
                                     item.lengthString,
                                     item.downloadProgressString];
    }
        
    if( item.downloadProgress < 1.0f )
    {
            if( !_isSelectOnly )
            {
                // configure priority segment control
                [cell.prioritySegment addTarget:self action:@selector(prioritySegmentToggled:) forControlEvents:UIControlEventValueChanged];
                cell.prioritySegment.dataObject = @(item.rpcIndex);
                cell.prioritySegment.selectedSegmentIndex = item.priority + 1;
                cell.prioritySegment.enabled = YES;
                cell.prioritySegment.hidden = NO;
            }
            
            // configure left checkBox control
            [cell.checkBox addTarget:self action:@selector(toggleFileDownloading:) forControlEvents:UIControlEventValueChanged];
            cell.checkBox.dataObject = item;
            
            if( !item.wanted || _isSelectOnly )
            {
                cell.prioritySegment.hidden = YES;
                
                if( !item.wanted )
                {
                    cell.iconImg.tintColor = [UIColor grayColor];
                    cell.nameLabel.textColor = [UIColor grayColor];
                    cell.checkBox.color = [UIColor grayColor];
                }
            }
            else
            {
                cell.nameLabelTrailConstraint.priority = 750;
                cell.nameLabelTrailToSegmentConstraint.priority = 751;
            }
            
            cell.checkBox.on = item.wanted;
            cell.checkBox.color = cell.checkBox.on ? cell.tintColor : [UIColor grayColor];
    }
    else
    {
        cell.checkBox.hidden = YES;
    }
}

- (void)updateFolderCell:(FileListFSCell *)cell withFSItem:(FSItem *)item
{
    cell.nameLabel.text = item.name;
    cell.iconImg.image =  item.isCollapsed ? _iconImgFolderClosed : _iconImgFolderOpened;
    
    // make indentation
    float leftIdent = ( (item.level - 1) * FILELISTFSCELL_LEFTLABEL_LEVEL_INDENTATION ) + 8;
    float checkBoxWidth = 33;
    
    if( _isFullyLoaded )
    {
        cell.checkBox.hidden = YES;
        checkBoxWidth = 0;
    }
    else
        cell.checkBox.hidden = NO;
    
    cell.checkBoxLeadConstraint.constant = leftIdent;
    cell.checkBoxWidthConstraint.constant = checkBoxWidth;
    
    cell.iconImg.tintColor = cell.tintColor;            // default (blue) tintColor
    cell.prioritySegment.hidden = YES;                  // by default folders don't have priority segment
    cell.nameLabel.textColor = [UIColor blackColor];    // by default file/folder names are black
    
    cell.nameLabelTrailConstraint.priority = 751;
    cell.nameLabelTrailToSegmentConstraint.priority = 750;
    
    cell.touchView.userInteractionEnabled = NO;
    
    if (_isSelectOnly)
    {
          cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(  @"%i files, %@", @"" ), item.filesCount, item.lengthString];
    }
    else
    {
            cell.detailLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%i files, %@ of %@, %@ downloaded", @""),
                                     item.filesCount,
                                     item.bytesComplitedString,
                                     item.lengthString,
                                     item.downloadProgressString];
    }
        
    if( item.downloadProgress < 1.0 )
    {
            BOOL isAllWanted = item.wanted;
            // get info for files within folder
            cell.checkBox.on = isAllWanted;
            cell.checkBox.color = isAllWanted ? cell.tintColor : [UIColor grayColor];
            cell.nameLabel.textColor = isAllWanted ? [UIColor blackColor] : [UIColor grayColor];
            cell.iconImg.tintColor = isAllWanted ? cell.tintColor : [UIColor grayColor];
            
            // add recognizer for unwanted files
            cell.checkBox.dataObject = item;
            [cell.checkBox addTarget:self action:@selector(toggleFolderDownloading:) forControlEvents:UIControlEventValueChanged];
    }
    else
    {
         cell.checkBox.hidden = YES;
    }
        
    // Add tap handeler for folder - open/close
    [cell.touchView layoutIfNeeded];
    UITapGestureRecognizer *tapFolderRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(folderTapped:)];
    tapFolderRec.dataObject = item;
        
    cell.touchView.userInteractionEnabled = YES;
    [cell.touchView addGestureRecognizer:tapFolderRec];
}

@end
