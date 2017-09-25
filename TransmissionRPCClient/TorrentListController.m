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
#import "GlobalConsts.h"

#define STOP_ALL_TORRENTS_TAG   0
#define START_ALL_TORRENTS_TAG  1

@interface TorrentListController () <UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation TorrentListController

{
    TorrentListCell *_editCell;
    NSMutableArray  *_catitems;  // array of StatusCategoryItem objects
    
    UIBarButtonItem *_stopAllButton;
    UIBarButtonItem *_startAllButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _catitems = [NSMutableArray array];
    
    _stopAllButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconStopAll22x22"] style:UIBarButtonItemStylePlain target:self action:@selector(stopAllTorrentsButtonPressed)];
    
    _startAllButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconStartAll22x22"] style:UIBarButtonItemStylePlain target:self action:@selector(startAllTorrentsButtonPressed)];
    
    self.navigationItem.rightBarButtonItems = nil;
}


- (void)stopAllTorrentsButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Stop all torrents", @"")
                                                    message:NSLocalizedString(@"Do you want to stop all torrents?", @"")
                                                   delegate:self cancelButtonTitle: NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    alert.dataObject = @(STOP_ALL_TORRENTS_TAG);
    [alert show];
}

- (void)startAllTorrentsButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Start all torrents", @"")
                                                    message:NSLocalizedString(@"Do you want to start all torrents?", @"")
                                                   delegate:self cancelButtonTitle: NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    alert.dataObject = @(START_ALL_TORRENTS_TAG);
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int ACTION_TAG = [alertView.dataObject intValue];
    
    if( buttonIndex != alertView.cancelButtonIndex && _delegate )
    {
        if( ACTION_TAG == STOP_ALL_TORRENTS_TAG &&
           [_delegate respondsToSelector:@selector(torrentListStopAllTorrents)] )
            [_delegate torrentListStopAllTorrents];
        
        else if( ACTION_TAG == START_ALL_TORRENTS_TAG &&
                [_delegate respondsToSelector:@selector(torrentListStartAllTorrents)] )
            [_delegate torrentListStartAllTorrents];
    }
}

// update model to the new state from @items
- (void)setItems:(StatusCategory *)items
{
    if( !items && !_catitems )
    {
        self.errorMessage = nil;
        [self.tableView reloadData];
        return;
    }
    
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
    
    NSUInteger maxSections = MAX(newCats.count, _catitems.count);
    for( NSUInteger i = 0; i < maxSections; i ++ )
    {
        StatusCategoryItem *newCat = i < newCats.count ?  newCats[i] : nil;
        StatusCategoryItem *curCat = i < _catitems.count ? _catitems[i] : nil;
        
        if( curCat == nil )
        {
            // INSERT SECTION
            [idxSectionToAdd addIndex:i];
        }
        else if ( newCat == nil )
        {
            // DELETE
            [idxSectionToRemove addIndex:i];
        }
        else if( [curCat.title isEqualToString:newCat.title] )
        {
            // UPDATE SECTION
            [idxSectionToUpdate addIndex:i];
            
            NSUInteger maxRows = MAX(curCat.items.count, newCat.items.count);
            for( NSUInteger row = 0; row < maxRows; row++)
            {
                TRInfo *infoNew = row < newCat.items.count ? newCat.items[row] : nil;
                TRInfo *infoCur = row < curCat.items.count ? curCat.items[row] : nil;
                
                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:i];
                
                if( infoNew == nil )
                {
                    // DELETE
                    [idxPathsToRemove addObject:path];
                }
                else if ( infoCur == nil )
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
        else
        {
            // RELOAD SECTION
            [idxSectionToReload addIndex:i];
        }
    }
    
    
    // now we update model
    _items = items;
    _catitems = newCats;
    
    if( idxSectionToAdd.count > 0 ||
        idxSectionToReload.count > 0 ||
        idxSectionToRemove.count > 0 ||
        idxPathsToAdd.count > 0 ||
        idxPathsToReload.count > 0 ||
        idxPathsToRemove.count > 0 )
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
        
    
    self.navigationItem.rightBarButtonItems =  ( _catitems && _catitems.count > 0 ) ?  @[ _stopAllButton, _startAllButton ] : nil;
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
        UIActionSheet *action = [[UIActionSheet alloc]
                                 initWithTitle:[NSString stringWithFormat: NSLocalizedString(@"Remove torrent: %@?", @""), cell.name.text]
                                 delegate:self
                                 cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                 destructiveButtonTitle: NSLocalizedString(@"Remove", @"")
                                 otherButtonTitles: NSLocalizedString(@"Remove with data", @""), nil];
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
        self.infoMessage =  NSLocalizedString(@"There are no torrents to show.", @"TorrentList background message");
    
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
    
    // reset unfinished progress
    cell.progressBar.downloadedProgress = nil;
    
    UIImage *btnImg;
    UIColor *btnTintColor;
    
    if ( info.isSeeding )
    {
        progressBarColor = [UIColor seedColor];
        detailInfo = [NSString stringWithFormat: NSLocalizedString(@"Seeding to %i of %i peers",@""),
                      info.peersGettingFromUs, info.peersConnected ];
        cell.downloadRate.text = [NSString stringWithFormat:NSLocalizedString(@"↑UL: %@", @""), info.uploadRateString];
        cell.size.text = [NSString stringWithFormat: NSLocalizedString(@"%@, uploaded %@ (Ratio %0.2f)", @""),
                          info.downloadedSizeString,
                          info.uploadedEverString,
                          info.uploadRatio];
        
        // fix: Show actual downloaded size
        if( ![info.haveValidString isEqual:info.downloadedSizeString] )
        {
            cell.size.text = [NSString stringWithFormat: NSLocalizedString( @"%@ of %@, uploaded %@ (Ratio %0.2f)", @"" ),
                              info.haveValidString,
                              info.totalSizeString,
                              info.uploadedEverString,
                              info.uploadRatio];
            
            cell.progressBar.downloadedProgress = @((CGFloat)info.haveValid / (CGFloat)info.totalSize);
        }
        
        cell.statusIcon.iconType = IconCloudTypeUpload;
        info.uploadRate > 0 ? [cell.statusIcon playUploadAnimation] : [cell.statusIcon stopUploadAnimation];
        
        btnImg = [UIImage iconPause];
        btnTintColor = [UIColor stopColor];
    }
    else if( info.isDownloading )
    {
        detailInfo = [NSString stringWithFormat: NSLocalizedString(@"Downloading from %i of %i peers, ETA: %@", @""),
                      info.peersSendingToUs, info.peersConnected, info.etaTimeString ];
        cell.downloadRate.text = [NSString stringWithFormat:NSLocalizedString(@"↓DL: %@", @""), info.downloadRateString];
        cell.uploadRate.text = [NSString stringWithFormat:NSLocalizedString(@"↑UL: %@", @""), info.uploadRateString];
        //cell.size.text = [NSString stringWithFormat:  NSLocalizedString(@"%@ of %@", @""), info.downloadedEverString, info.totalSizeString ];
        cell.size.text = [NSString stringWithFormat: NSLocalizedString( @"%@ of %@, uploaded %@ (Ratio %0.2f)", @"" ),
                          info.downloadedEverString,
                          info.totalSizeString,
                          info.uploadedEverString,
                          info.uploadRatio];
        
        cell.statusIcon.iconType = IconCloudTypeDownload;
        info.downloadRate > 0 ? [cell.statusIcon playDownloadAnimation] : [cell.statusIcon stopDownloadAnimation];
        
        cell.buttonStopResume.imageView.image = [UIImage iconPlay];
        btnImg = [UIImage iconPause];
        btnTintColor = [UIColor stopColor];
    }
    else if( info.isStopped )
    {
        detailInfo =  NSLocalizedString(@"Paused", @"TorrentListController torrent info");
        progressBarColor = [UIColor stopColor];
        cell.downloadRate.text = NSLocalizedString(@"no activity", @"");
        //cell.size.text = [NSString stringWithFormat: NSLocalizedString(@"%@ of %@, uploaded %@ (Ratio %0.2f)", @""), info.haveValidString, info.totalSizeString, info.uploadedEverString, info.uploadRatio];
        
        cell.size.text = [NSString stringWithFormat: NSLocalizedString(@"%@, uploaded %@ (Ratio %0.2f)", @""),
                          info.downloadedSizeString,
                          info.uploadedEverString,
                          info.uploadRatio];
        
        if( ![info.haveValidString isEqual:info.downloadedSizeString] )
        {
            cell.size.text = [NSString stringWithFormat: NSLocalizedString( @"%@ of %@, uploaded %@ (Ratio %0.2f)", @"" ),
                              info.haveValidString,
                              info.totalSizeString,
                              info.uploadedEverString,
                              info.uploadRatio];
            
            // FIX : if this torrent is not fully downloaded there is no part of unfinished progress
            if( info.percentsDone >= 1.0 )
                cell.progressBar.downloadedProgress = @((CGFloat)info.haveValid / (CGFloat)info.totalSize);
        }
        
        
        cell.statusIcon.iconType = IconCloudTypeStop;
        cell.buttonStopResume.imageView.image = [UIImage iconPlay];
        btnImg = [UIImage iconPlay];
        btnTintColor = [UIColor seedColor];
    }
    else if( info.isChecking )
    {
        detailInfo =  NSLocalizedString(@"Checking data ...", @"");
        progressBarColor = [UIColor checkColor];
        cell.progressBar.progress = info.recheckProgress;
        cell.progressPercents.text = info.recheckProgressString;
        
        // NSString *totSize = formatByteCount( (long long)((double)info.haveValid / info.recheckProgress) );
        
        // FIX: need to corect and test
        //cell.size.text = [NSString stringWithFormat: NSLocalizedString(@"%@ of %@", @""), info.haveValidString, totSize];
        cell.size.text = [NSString stringWithFormat: NSLocalizedString(@"%@ of %@", @""), info.haveValidString, info.totalSizeString];

        //cell.statusIcon.image = [UIImage iconCheck];
        cell.statusIcon.iconType = IconCloudTypeCheck;
        [cell.statusIcon playCheckAnimation];
        
        cell.buttonStopResume.hidden = YES;
    }
    
    // because error torrent has native status as "stopped" we
    // should handle this case aside of common "if"
    if( info.isError )
    {
        detailInfo = [NSString stringWithFormat: NSLocalizedString(@"Error: %@", @""), info.errorString];
        progressBarColor = [UIColor errorColor];
        cell.size.text = [NSString stringWithFormat: NSLocalizedString(@"%@ of %@, uploaded %@ (Ratio %0.2f)", @""), info.downloadedSizeString, info.totalSizeString, info.uploadedEverString, info.uploadRatio];
        
        //cell.statusIcon.image = [UIImage iconError];
        cell.statusIcon.iconType = IconCloudTypeError;
    }
    
    cell.progressBar.tintColor = progressBarColor;
    cell.peersInfo.text = detailInfo;
    cell.statusIcon.tintColor = progressBarColor;
    cell.buttonStopResume.imageView.image = btnImg;
    cell.buttonStopResume.tintColor = btnTintColor;
    
    // set icons of limits
    cell.iconRateLimit.hidden = !(info.downloadLimitEnabled || info.uploadLimitEnabled);
    cell.iconRatioLimit.hidden = !(info.seedRatioMode > 0);
    cell.iconIdleLimit.hidden = !(info.seedIdleMode > 0);
    
    cell.iconRateLimit.image = [cell.iconRateLimit.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconIdleLimit.image = [cell.iconIdleLimit.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconRatioLimit.image = [cell.iconRatioLimit.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
