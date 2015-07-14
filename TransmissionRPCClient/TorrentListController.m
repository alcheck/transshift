//
//  TorrentListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListController.h"
#import "TorrentListCell.h"
#import "NSObject+DataObject.h"

@interface TorrentListController () <UIActionSheetDelegate>

@end

@implementation TorrentListController

{
    TorrentListCell *_editCell;
    NSMutableArray  *_catitems;  // array of StatusCategoryItem objects
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _catitems = [NSMutableArray array];
}

// searchs categoryitem in @arr by its title and returns it, or nil if not found
- (StatusCategoryItem*)categoryFrom:(NSArray*)arr byTitle:(NSString*)title
{
    for (StatusCategoryItem *i in arr )
    {
        if( [i.title isEqualToString:title] )
            return i;
    }
    
    return nil;
}

- (TRInfo*)infoFromArray:(NSArray*)array withId:(int)torrentId
{
    for( TRInfo* info in array )
        if( info.trId == torrentId )
            return info;
        
    return nil;
}


- (void)updateIndexesForNewCategoryItem:(StatusCategoryItem*)newCat
                        currentCategory:(StatusCategoryItem*)curCat
                           indexesToAdd:(NSMutableArray*)idxPathsToAdd
                        indexesToRemove:(NSMutableArray*)idxPathsToRemove
                        indexesToReload:(NSMutableArray*)idxPathsToReload
                       withSectionIndex:(NSUInteger)section

{
    // RELOAD + UPDATE
    if( curCat.count == newCat.count )
    {
        for( NSUInteger row = 0; row < newCat.items.count; row++)
        {
            TRInfo *infoCur = curCat.items[row];
            TRInfo *infoNew = newCat.items[row];
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            
            if( infoCur.trId == infoNew.trId )
            {
                // UPDATE
                TorrentListCell *cell = (TorrentListCell*)[self.tableView cellForRowAtIndexPath:path];
                if( cell )
                    [self updateCell:cell withTorrentInfo:infoNew];
            }
            else
            {
                // RELOAD
                [idxPathsToReload addObject:path];
            }
        }
    }
    // RELOAD + UPDATE + DELETE
    else if( curCat.count > newCat.count )
    {
        for( NSUInteger row = 0; row < curCat.items.count; row++)
        {
            TRInfo *infoNew = row < newCat.items.count ? newCat.items[row] : nil;
            TRInfo *infoCur = curCat.items[row];
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            
            if( infoNew == nil )
            {
                // DELETE
                [idxPathsToRemove addObject:path];
            }
            else if( infoCur.trId == infoNew.trId )
            {
                // UPDATE
                TorrentListCell *cell = (TorrentListCell*)[self.tableView cellForRowAtIndexPath:path];
                if( cell )
                    [self updateCell:cell withTorrentInfo:infoNew];
            }
            else
            {
                // RELOAD
                [idxPathsToReload addObject:path];
            }
        }
    }
    else
    // RELOAD + UPDATE + INSERT
    {
        for( NSUInteger row = 0; row < newCat.items.count; row++)
        {
            TRInfo *infoNew = newCat.items[row];
            TRInfo *infoCur = row < curCat.items.count ? curCat.items[row] : nil;
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            
            if( infoCur == nil )
            {
                // INSERT
                [idxPathsToAdd addObject:path];
            }
            else if( infoCur.trId == infoNew.trId )
            {
                // UPDATE
                TorrentListCell *cell = (TorrentListCell*)[self.tableView cellForRowAtIndexPath:path];
                if( cell )
                    [self updateCell:cell withTorrentInfo:infoNew];
            }
            else
            {
                // RELOAD
                [idxPathsToReload addObject:path];
            }
        }
    }
}

// update model to the new state from @items
- (void)setItems:(StatusCategory *)items
{
    // get mutable copy of non empty CategoryItems (sections of the table)
    NSMutableArray *newCats = [items mutableCopyOfNonEmptyItems];
    
    // section indexes
    NSMutableIndexSet *idxSectionToReload  = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *idxSectionToAdd     = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *idxSectionToRemove  = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *idxSectionToUpdate  = [NSMutableIndexSet indexSet];
    
    // NSIndex paths for sections
    NSMutableArray *idxPathsToRemove    = [NSMutableArray array];
    NSMutableArray *idxPathsToAdd       = [NSMutableArray array];
    NSMutableArray *idxPathsToReload    = [NSMutableArray array];
    
    // UPDATE OR RELOAD SECTIONS
    if( newCats.count == _catitems.count )
    {
        for( NSUInteger i = 0; i < newCats.count; i ++ )
        {
            StatusCategoryItem *curCat = _catitems[i];
            StatusCategoryItem *newCat = newCats[i];
            
            if( [curCat.title isEqualToString:newCat.title] )
            {
                // UPDATE SECTION
                [self updateIndexesForNewCategoryItem:newCat
                                      currentCategory:curCat
                                         indexesToAdd:idxPathsToAdd
                                      indexesToRemove:idxPathsToRemove
                                      indexesToReload:idxPathsToReload
                                     withSectionIndex:i];
                
                [idxSectionToUpdate addIndex:i];
            }
            else
            {
                // RELOAD SECTION
                [idxSectionToReload addIndex:i];
            }
        }
    }
    // UPDATE, RELOAD AND INSERT
    else if( newCats.count > _catitems.count )
    {
        for( NSUInteger i = 0; i < newCats.count; i ++ )
        {
            StatusCategoryItem *newCat = newCats[i];
            StatusCategoryItem *curCat = i < _catitems.count ? _catitems[i] : nil;
            
            if( curCat == nil )
            {
                // INSERT SECTION
                [idxSectionToAdd addIndex:i];
            }
            else if( [curCat.title isEqualToString:newCat.title] )
            {
                // UPDATE SECTION
                [self updateIndexesForNewCategoryItem:newCat
                                      currentCategory:curCat
                                         indexesToAdd:idxPathsToAdd
                                      indexesToRemove:idxPathsToRemove
                                      indexesToReload:idxPathsToReload
                                     withSectionIndex:i];
                
                [idxSectionToUpdate addIndex:i];

            }
            else
            {
                // RELOAD SECTION
                [idxSectionToReload addIndex:i];
            }
        }

    }
    // UPDATE, RELOAD AND DELETE
    else
    {
        for( NSUInteger i = 0; i < _catitems.count; i ++ )
        {
            StatusCategoryItem *newCat = i < newCats.count ? newCats[i] : nil;
            StatusCategoryItem *curCat = _catitems[i];
            
            if( newCat == nil )
            {
                // INSERT SECTION
                [idxSectionToRemove addIndex:i];
            }
            else if( [curCat.title isEqualToString:newCat.title] )
            {
                // UPDATE SECTION
                [self updateIndexesForNewCategoryItem:newCat
                                      currentCategory:curCat
                                         indexesToAdd:idxPathsToAdd
                                      indexesToRemove:idxPathsToRemove
                                      indexesToReload:idxPathsToReload
                                     withSectionIndex:i];
                
                [idxSectionToUpdate addIndex:i];

            }
            else
            {
                // RELOAD SECTION
                [idxSectionToReload addIndex:i];
            }
        }
    }
    
    if( newCats )
    {
        // now we update model
        _items = items;
        _catitems = newCats;
    }
    
    if( idxSectionToAdd.count > 0 ||
        idxSectionToReload.count > 0 ||
        idxSectionToRemove.count > 0 ||
        idxSectionToUpdate.count > 0 )
    {
        [self.tableView beginUpdates];
        
        if( idxSectionToAdd.count > 0 )
            [self.tableView insertSections:idxSectionToAdd withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( idxSectionToRemove.count > 0 )
            [self.tableView deleteSections:idxSectionToRemove withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( idxSectionToReload.count > 0 )
            [self.tableView reloadSections:idxSectionToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( idxPathsToAdd.count > 0 )
            [self.tableView insertRowsAtIndexPaths:idxPathsToAdd withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( idxPathsToRemove.count > 0 )
            [self.tableView deleteRowsAtIndexPaths:idxPathsToRemove withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( idxPathsToReload.count > 0 )
            [self.tableView reloadRowsAtIndexPaths:idxPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        [self.tableView endUpdates];
    }
        
    
    //NSLog(@"Sections[RELOAD:%i, ADD:%i, REMOVE:%i, UPDATE:%i]",
    //      idxSectionToReload.count, idxSectionToAdd.count, idxSectionToRemove.count, idxSectionToUpdate.count);

    // table view batch update
    //[self.tableView reloadData];
}

#pragma mark - UIActionSheet delegate methods (allow to delete torrent with swipe-to delete gesture)

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView setEditing:NO animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView setEditing:NO animated:NO];
    
    if( buttonIndex == actionSheet.cancelButtonIndex )
        return;
    
    BOOL removeWithData = (buttonIndex != actionSheet.destructiveButtonIndex);
    
    if( _delegate && [_delegate respondsToSelector:@selector(torrentListRemoveTorrentWithId:removeWithData:)])
        [_delegate torrentListRemoveTorrentWithId:_editCell.torrentId removeWithData:removeWithData];
}

#pragma mark - UISplitViewControllerDelegate methods

- (void)setPopoverButtonTitle:(NSString *)popoverButtonTitle
{
    _popoverButtonTitle = popoverButtonTitle;
    if( self.splitViewController && self.navigationItem.leftBarButtonItem )
       [self.navigationItem.leftBarButtonItem setTitle:popoverButtonTitle];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.popoverButtonTitle;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if( self.navigationItem.leftBarButtonItem == barButtonItem )
        self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - UITableView delegate/datasource methods

// torrent is selected, signal to delegate with
// correspondend torrent id
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // getting torrent id from selected cell
    // and delegating processing this event to delegate
    if( _delegate && [_delegate respondsToSelector:@selector(showDetailedInfoForTorrentWithId:)])
    {
        TorrentListCell *cell = (TorrentListCell*)[tableView cellForRowAtIndexPath:indexPath];
        [_delegate showDetailedInfoForTorrentWithId:cell.torrentId];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        TorrentListCell *cell = (TorrentListCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        // show action sheet
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Remove torrent %@?", cell.name.text]
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Remove"
                                                   otherButtonTitles:@"Remove with data", nil];
        CGRect r = cell.bounds;
        r.origin.x = r.size.width - 30;
        
        _editCell = cell;
        
        [action showFromRect:r inView:cell animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // check how many sections do we have
    //if ( _items && _items.countOfNonEmptyItems > 0 )
    if( _catitems && _catitems.count > 0 )
    {
        self.infoMessage = nil;
        self.errorMessage = nil;
        //return _items.countOfNonEmptyItems;
        return _catitems.count;
    }
    
    if( _items && _items.emptyTitle )
        self.infoMessage = _items.emptyTitle;
    else
        self.infoMessage = @"There are no torrents to show.";
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    StatusCategoryItem *item = _catitems[section];
    //StatusCategoryItem *item = [_items nonEmptyItemAtIndex:(int)section];
    
    return item.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    StatusCategoryItem *item = _catitems[section];
    //StatusCategoryItem *item = [_items nonEmptyItemAtIndex:(int)section];
    
    return item.count;
}

// returns configured cell for torrent
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TorrentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TORRENTLIST forIndexPath:indexPath];
    
    //StatusCategoryItem *item = [_items nonEmptyItemAtIndex:(int)indexPath.section];
    StatusCategoryItem *item = _catitems[indexPath.section];
    
    TRInfo *info = item.items[indexPath.row];
    
    [self updateCell:cell withTorrentInfo:info];
    
    return cell;
}

- (void)updateCell:(TorrentListCell*)cell withTorrentInfo:(TRInfo*)info
{
    cell.torrentId = info.trId;
    
    cell.name.text = info.name;
    cell.progressPercents.text = info.percentsDoneString;
    cell.progressBar.progress = info.percentsDone;
    cell.downloadRate.text = @"";
    cell.uploadRate.text = @"";
    cell.progressBar.trackTintColor = [UIColor progressBarTrackColor];
    //cell.buttonStopResume.imageView.image = nil;
    cell.buttonStopResume.hidden = NO;
    cell.buttonStopResume.enabled = YES;
    cell.buttonStopResume.dataObject = info;
    [cell.buttonStopResume addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *progressBarColor = cell.tintColor;
    NSString *detailInfo = @"";
    
    UIImage *btnImg;
    UIColor *btnTintColor;
    
    if ( info.isSeeding )
    {
        progressBarColor = [UIColor seedColor];
        detailInfo = [NSString stringWithFormat:@"Seeding to %i of %i peers", info.peersGettingFromUs, info.peersConnected ];
        cell.downloadRate.text = [NSString stringWithFormat:@"↑UL: %@/s", info.uploadRateString];
        cell.size.text = [NSString stringWithFormat:@"%@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.uploadedEverString, info.uploadRatio];
        cell.statusIcon.image = [UIImage iconUpload];
        btnImg = [UIImage iconPause];
        btnTintColor = [UIColor stopColor];
    }
    else if( info.isDownloading )
    {
        detailInfo = [NSString stringWithFormat:@"Downloading from %i of %i peers, ETA: %@", info.peersSendingToUs, info.peersConnected, info.etaTimeString ];
        cell.downloadRate.text = [NSString stringWithFormat:@"↓DL: %@/s", info.downloadRateString];
        cell.uploadRate.text = [NSString stringWithFormat:@"↑UL: %@/s", info.uploadRateString];
        cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.totalSizeString ];
        cell.statusIcon.image = [UIImage iconDownload];
        cell.buttonStopResume.imageView.image = [UIImage iconPlay];
        btnImg = [UIImage iconPause];
        btnTintColor = [UIColor stopColor];
    }
    else if( info.isStopped )
    {
        detailInfo = @"Paused";
        progressBarColor = [UIColor stopColor];
        cell.downloadRate.text = @"no activity";
        cell.size.text = [NSString stringWithFormat:@"%@ of %@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.totalSizeString, info.uploadedEverString, info.uploadRatio];
        cell.statusIcon.image = [UIImage iconStop];
        cell.buttonStopResume.imageView.image = [UIImage iconPlay];
        btnImg = [UIImage iconPlay];
        btnTintColor = [UIColor seedColor];
    }
    else if( info.isChecking )
    {
        detailInfo = @"Checking data ...";
        progressBarColor = [UIColor checkColor];
        cell.progressBar.progress = info.recheckProgress;
        cell.progressPercents.text = info.recheckProgressString;
        cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.downloadedEverString];
        cell.statusIcon.image = [UIImage iconCheck];
        cell.buttonStopResume.hidden = YES;
    }
    
    // because error torrent has native status as "stopped" we
    // should handle this case aside of common "if"
    if( info.isError )
    {
        detailInfo = [NSString stringWithFormat:@"Error: %@", info.errorString];
        progressBarColor = [UIColor errorColor];
        cell.size.text = [NSString stringWithFormat:@"%@ of %@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.totalSizeString, info.uploadedEverString, info.uploadRatio];
        cell.statusIcon.image = [UIImage iconError];
    }
    
    cell.progressBar.tintColor = progressBarColor;
    cell.peersInfo.text = detailInfo;
    cell.statusIcon.tintColor = progressBarColor;
    cell.buttonStopResume.imageView.image = btnImg;
    cell.buttonStopResume.tintColor = btnTintColor;
}

- (void)playPauseButtonPressed:(UIButton*)sender
{
    TRInfo *info = sender.dataObject;
    sender.enabled = NO;
    
    if( _delegate )
    {
        if ( info.isStopped &&
            [_delegate respondsToSelector:@selector(torrentListResumeTorrentWithId:)] )
        {
            [_delegate torrentListResumeTorrentWithId:info.trId];
        }
        else if( (info.isSeeding || info.isDownloading) &&
                [_delegate respondsToSelector:@selector(torrentListStopTorrentWithId:)])
        {
            [_delegate torrentListStopTorrentWithId:info.trId];
        }
    }
}

@end
