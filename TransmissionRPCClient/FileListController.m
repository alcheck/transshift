//
//  FileListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "FileListController.h"

#import "FSDirectory.h"
#import "FileListFSCell.h"
#import "FileListTouchAreaView.h"
#import "TRFileInfo.h"
#import "NSObject+DataObject.h"

#define ICON_FILE             @"iconFile"
#define ICON_FOLDER_OPENED    @"iconFolderOpened"
#define ICON_FOLDER_CLOSED    @"iconFolderClosed"

@interface FileListController () <FileListTouchAreaDelegate>
@end

@implementation FileListController

{
    UIImage *_iconImgFile;
    UIImage *_iconImgFolderOpened;
    UIImage *_iconImgFolderClosed;
    
    //BOOL     _isSelectOnly;
    FSItem  *_curItem;
    
    BOOL     _needUpdateFolders;
    BOOL     _fileJustFinished;
    
    UIBarButtonItem *_btnCheckAll;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    
    [self.refreshControl addTarget:self action:@selector(askDelegateForDataUpdate) forControlEvents:UIControlEventValueChanged];
    
    _btnCheckAll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconCheckAll22x22"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleDownloadAllItems)];
    
    _btnCheckAll.enabled = (_fsDir != nil);
    if( _isFullyLoaded )
        _btnCheckAll.enabled = NO;
    
    UIBarButtonItem *btnSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[ _btnCheckAll, btnSpacer ];
 }

- (void)toggleDownloadAllItems
{
    FSItem *item = _fsDir.rootItem;

    BOOL wanted = !item.wanted;
    item.wanted = wanted;
    
    if( !_selectOnly )
    {
        if( _delegate && wanted &&
           [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)])
        {
            
            NSArray *fileIndexes = item.rpcFileIndexes;
            [_delegate fileListControllerResumeDownloadingFilesWithIndexes:fileIndexes
                                                          forTorrentWithId:_torrentId];
        }
        else if( _delegate && !wanted &&
                [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)])
        {
            
            NSArray *fileIndexes = item.rpcFileIndexes;
            [_delegate fileListControllerStopDownloadingFilesWithIndexes:fileIndexes
                                                        forTorrentWithId:_torrentId];
        }
        
        _btnCheckAll.enabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem.title =  NSLocalizedString(@"Info", @"FileListController nav left button title");
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)askDelegateForDataUpdate
{
    [self.refreshControl endRefreshing];
    
    if( !_isFullyLoaded &&  _delegate && [_delegate respondsToSelector:@selector(fileListControllerNeedUpdateFilesForTorrentWithId:)])
        [_delegate fileListControllerNeedUpdateFilesForTorrentWithId:_torrentId];
}

- (void)stoppedToDownloadFilesWithIndexes:(NSArray *)indexes
{
    _btnCheckAll.enabled = YES;
        
    [self askDelegateForDataUpdate];
}

- (void)resumedToDownloadFilesWithIndexes:(NSArray *)indexes
{
    _btnCheckAll.enabled = YES;
    
    [self askDelegateForDataUpdate];
}

- (void)setFsDir:(FSDirectory *)fsDir
{
    _fsDir = fsDir;
    _isFullyLoaded = fsDir.rootItem.downloadProgress >= 1.0f;
    
    [_fsDir recalcRowIndexes];
    
    _btnCheckAll.enabled = _selectOnly ? NO : !_isFullyLoaded;
    
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
        
        if ( _curItem.waitingForWantedUpdate &&  fileStat.wanted == _curItem.wanted )
        {
            needUpdateCell = YES;
        }
        else if( fileStat.wanted != _curItem.wanted )
        {
            needUpdateCell = YES;
        }
        
        if( fileStat.priority != _curItem.priority )
        {
            needUpdateCell = YES;
            _curItem.priority = fileStat.priority;
        }
        
        if( needUpdateCell )
        {
            _needUpdateFolders = YES;
            
            NSUInteger row = _curItem.rowIndex;
            
            if( row != FSITEM_INDEXNOTFOUND )
            {
                // get cell
                FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                if( cell )
                {
                    _fileJustFinished = justDownloaded;
                    
                    if( _curItem.waitingForWantedUpdate && _curItem.wanted == fileStat.wanted )
                    {
                        [self updateFileCell:cell withFSItem:_curItem updateWanted:NO];
                        cell.checkBox.enabled = YES;
                        _curItem.waitingForWantedUpdate = NO;
                    }
                    else
                        [self updateFileCell:cell withFSItem:_curItem updateWanted:YES];
                    
                    if( !cell.prioritySegment.enabled && cell.prioritySegment.selectedSegmentIndex == (fileStat.priority + 1) )
                        cell.prioritySegment.enabled = YES;
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
        NSUInteger row = _curItem.rowIndex;
        
        if( row != FSITEM_INDEXNOTFOUND )
        {
            FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            if( cell )
            {
                [self updateFolderCell:cell withFSItem:_curItem updateWanted:NO];
                
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
    FSItem *item = sender.dataObject;
    
    BOOL wanted = !item.wanted;
    item.wanted = wanted;
    NSUInteger idx = item.rowIndex;
    
    item.waitingForWantedUpdate = YES;

    if( idx != FSITEM_INDEXNOTFOUND )
    {
        FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        if( cell )
        {
            [self updateFolderCell:cell withFSItem:item updateWanted:NO];
            //[cell.checkBox setOn:wanted animated:YES];
            //cell.checkBox.enabled = _selectOnly;
        }
    }
    
    [self updateFilesForFolderItem:item wanted:wanted];
    
    [_fsDir setNeedToRecalcStats];
    [self updateParentFolderForItem:item];
    
    if( _delegate && wanted &&
       [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        
        NSArray *fileIndexes = item.rpcFileIndexes;
        [_delegate fileListControllerResumeDownloadingFilesWithIndexes:fileIndexes
                                                      forTorrentWithId:_torrentId];
    }
    else if( _delegate && !wanted &&
            [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)])
    {
        
        NSArray *fileIndexes = item.rpcFileIndexes;
        [_delegate fileListControllerStopDownloadingFilesWithIndexes:fileIndexes
                                                    forTorrentWithId:_torrentId];
    }
}

- (void)updateFilesForFolderItem:(FSItem *)item wanted:(BOOL)wanted
{
    for( FSItem *i in item.items )
    {
        i.waitingForWantedUpdate = YES;
        
        NSUInteger idx = i.rowIndex;
        
        if( idx != FSITEM_INDEXNOTFOUND )
        {
            FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            if( cell )
            {
                if( i.isFile )
                    [self updateFileCell:cell withFSItem:i updateWanted:NO];
                else
                    [self updateFolderCell:cell withFSItem:i updateWanted:NO];
                
                [cell.checkBox setOn:wanted animated:YES];
                cell.checkBox.enabled = _selectOnly;
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
    item.wanted = wanted;
    
    item.waitingForWantedUpdate = YES;
    
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow: item.rowIndex inSection:0];
    FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:idxPath];
    if( cell )
    {
        [self updateFileCell:cell withFSItem:item updateWanted:NO];
        //[cell.checkBox setOn:wanted animated:YES];
        cell.checkBox.enabled = _selectOnly;
    }
    
    [_fsDir setNeedToRecalcStats];
    [self updateParentFolderForItem:item];
  
    // update server settings for this torrent
    if( _delegate &&
         wanted   &&
         [_delegate respondsToSelector:@selector(fileListControllerResumeDownloadingFilesWithIndexes:forTorrentWithId:)] )
    {
        
        [_delegate fileListControllerResumeDownloadingFilesWithIndexes:@[@(item.rpcIndex)] forTorrentWithId:_torrentId];
    }
    else if( _delegate &&
             !wanted   &&
             [_delegate respondsToSelector:@selector(fileListControllerStopDownloadingFilesWithIndexes:forTorrentWithId:)] )
    {
        [_delegate fileListControllerStopDownloadingFilesWithIndexes:@[@(item.rpcIndex)] forTorrentWithId:_torrentId];
    }
}

- (void)updateParentFolderForItem:(FSItem *)item
{
    if( item.parent )
    {
        item = item.parent;
        
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:item.rowIndex inSection:0];
        
        FileListFSCell *cell = (FileListFSCell *)[self.tableView cellForRowAtIndexPath:idxPath];
        
        if( cell )
        {
            if(  cell.checkBox.on != item.wanted )
            {
                [self updateFolderCell:cell withFSItem:item updateWanted:NO];
                [cell.checkBox setOn:item.wanted animated:YES];
            }
        }
        
        // update parent of current item
        [self updateParentFolderForItem:item];
    }
}

- (void)prioritySegmentToggled:(UISegmentedControl*)sender
{
    int priority = (int)sender.selectedSegmentIndex - 1;
    
    if( _selectOnly )
    {
        return;
    }
    
    sender.enabled = NO;
    
    if( _delegate && [_delegate respondsToSelector:@selector(fileListControllerSetPriority:forFilesWithIndexes:forTorrentWithId:)])
    {
        [_delegate fileListControllerSetPriority:priority forFilesWithIndexes:@[sender.dataObject] forTorrentWithId:_torrentId];
    }
 }

// toggle collapse flag
- (void)folderTapped:(UITapGestureRecognizer*)sender
{
    FSItem *item = sender.dataObject;
    
    item.collapsed = !item.collapsed;
    [_fsDir recalcRowIndexes];
    
    NSInteger itemIndex = item.rowIndex;
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
        //cell.iconImg.image = item.isCollapsed ? _iconImgFolderClosed : _iconImgFolderOpened;
        item.isCollapsed ? [cell.icon playFolderCloseAnimation] : [cell.icon playFolderOpenAnimation];
    }
}

#pragma mark - Rename item
- (void)showRenameMenu:(UILongPressGestureRecognizer *)sender
{
    if( sender.state != UIGestureRecognizerStateRecognized )
        return;
    
    FileListTouchAreaView *touchView = sender.dataObject;
    [touchView becomeFirstResponder];
    
    UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle: touchView.isFile ?
                              NSLocalizedString( @"AlertRenameFileTitle" , nil) : NSLocalizedString( @"AlertRenameFolderTitle" , nil)
                                                        action:@selector(renameAction:)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = @[ renameItem ];
    
    // make some fix to the frame where menu will appear
    CGRect frame = touchView.frame;
    frame.origin.y += frame.size.height / 3;
    frame.origin.x += 50;
    frame.size.width /= 2;
    
    [menu setTargetRect:frame inView:touchView.superview];
    [menu setMenuVisible:YES animated:YES];
    
    //NSLog(@"FullPath: [%@]", touchView.itemPath);
}

#pragma mark - FileListTouchAreaDelegate methods
- (void)renameFileOrFolder:(BOOL)isFile fromOldName:(NSString *)oldName toNewName:(NSString *)newName
{
    if( _delegate && [_delegate respondsToSelector:@selector(fileListControllerRenameTorrent:oldItemName:newItemName:)] )
    {
        [_delegate fileListControllerRenameTorrent:_torrentId oldItemName:oldName newItemName:newName];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fsDir ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString( @"Files & Folders", nil );
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return  _selectOnly ? nil : NSLocalizedString( @"Long tap to rename file or folder", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fsDir.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListFSCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FILELISTFSCELL forIndexPath:indexPath];
    
    FSItem *item = [_fsDir itemAtIndex:indexPath.row];
    
    cell.nameLabel.text = item.name;

    if( item.isFolder )
        [self updateFolderCell:cell withFSItem:item updateWanted:YES];
    else
        [self updateFileCell:cell withFSItem:item updateWanted:YES];
    
    return cell;
}

- (void)updateFileCell:(FileListFSCell *)cell withFSItem:(FSItem *)item updateWanted:(BOOL)updateWanted
{
    // remove all old targets
    [cell.checkBox removeTarget:self action:@selector(toggleFileDownloading:) forControlEvents:UIControlEventValueChanged];
    [cell.checkBox removeTarget:self action:@selector(toggleFolderDownloading:) forControlEvents:UIControlEventValueChanged];
    
    if( _fileJustFinished )
    {
        _fileJustFinished = NO;
        [cell.icon playCheckFinishAnimation];
    }
    else
    {
        cell.icon.iconType = item.downloadProgress >= 1.0 ? IconFSTypeFileFinished : IconFSTypeFile;
    }
    cell.icon.downloadProgress = item.downloadProgress;
    
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
    
    cell.icon.tintColor = cell.tintColor;            // default (blue) tintColor
    cell.prioritySegment.hidden = YES;                  // by default folders don't have priority segment
    cell.nameLabel.textColor = [UIColor blackColor];    // by default file/folder names are black
    
    cell.nameLabelTrailConstraint.priority = 751;
    cell.nameLabelTrailToSegmentConstraint.priority = 750;
    
    cell.touchView.userInteractionEnabled = YES;

    if( !cell.longTapRecognizer )
    {
        cell.longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showRenameMenu:)];
        [cell.touchView addGestureRecognizer:cell.longTapRecognizer];
    }
    
    cell.touchView.delegate = self;
    cell.touchView.isFile = YES;
    cell.touchView.itemName = item.name;
    cell.touchView.itemPath = item.fullName;
    cell.longTapRecognizer.dataObject = cell.touchView;
    
    
    cell.prioritySegment.dataObject = item;
    cell.checkBox.dataObject = item;
    
    if (_selectOnly)
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
            if( !_selectOnly )
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
        
            if( !item.wanted || _selectOnly )
            {
                cell.prioritySegment.hidden = YES;
                
                if( !item.wanted )
                {
                    cell.icon.tintColor = [UIColor grayColor];
                    cell.nameLabel.textColor = [UIColor grayColor];
                    cell.checkBox.color = [UIColor grayColor];
                }
            }
            else
            {
                cell.nameLabelTrailConstraint.priority = 750;
                cell.nameLabelTrailToSegmentConstraint.priority = 751;
            }
        
            if( updateWanted )
                cell.checkBox.on = item.wanted;
        
            cell.checkBox.color = item.wanted ? cell.tintColor : [UIColor grayColor];
    }
    else
    {
        cell.checkBox.hidden = YES;
    }
    
    if( cell.tapRecognizer )
    {
        [cell.touchView removeGestureRecognizer:cell.tapRecognizer];
        cell.tapRecognizer = nil;
    }
}

- (void)updateFolderCell:(FileListFSCell *)cell withFSItem:(FSItem *)item   updateWanted:(BOOL)updateWanted
{
    // remove all old targets
    [cell.checkBox removeTarget:self action:@selector(toggleFileDownloading:) forControlEvents:UIControlEventValueChanged];
    [cell.checkBox removeTarget:self action:@selector(toggleFolderDownloading:) forControlEvents:UIControlEventValueChanged];

    //cell.nameLabel.text = item.name;
    //cell.iconImg.image =  item.isCollapsed ? _iconImgFolderClosed : _iconImgFolderOpened;
    cell.icon.iconType = item.isCollapsed ? IconFSTypeFolderClosed : IconFSTypeFolderOpened;
    
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
    
    cell.icon.tintColor = cell.tintColor;            // default (blue) tintColor
    cell.prioritySegment.hidden = YES;                  // by default folders don't have priority segment
    cell.nameLabel.textColor = [UIColor blackColor];    // by default file/folder names are black
    
    cell.nameLabelTrailConstraint.priority = 751;
    cell.nameLabelTrailToSegmentConstraint.priority = 750;
    
    cell.touchView.userInteractionEnabled = YES;
    
    if( !cell.longTapRecognizer )
    {
        cell.longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showRenameMenu:)];
        [cell.touchView addGestureRecognizer:cell.longTapRecognizer];
    }
    
    cell.touchView.delegate = self;
    cell.touchView.isFile = NO;
    cell.touchView.itemName = item.name;
    cell.touchView.itemPath = item.fullName;
    cell.longTapRecognizer.dataObject = cell.touchView;
    
    if ( _selectOnly )
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
            if( updateWanted )
                cell.checkBox.on = isAllWanted;
        
            cell.checkBox.color = isAllWanted ? cell.tintColor : [UIColor grayColor];
            cell.nameLabel.textColor = isAllWanted ? [UIColor blackColor] : [UIColor grayColor];
            cell.icon.tintColor = isAllWanted ? cell.tintColor : [UIColor grayColor];
            
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
    
    // add tap recognizer
    if( cell.tapRecognizer )
        [cell.touchView removeGestureRecognizer:cell.tapRecognizer];
    
    cell.tapRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(folderTapped:)];
    cell.tapRecognizer.dataObject = item;
        
    [cell.touchView addGestureRecognizer:cell.tapRecognizer];
}

@end
