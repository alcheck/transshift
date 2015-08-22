//
//  TrackerListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TrackerListController.h"
#import "TrackerInfoCell.h"
#import "NSObject+DataObject.h"

@interface TrackerListController () <UIActionSheetDelegate>

@end

@implementation TrackerListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateData:) forControlEvents:UIControlEventValueChanged];
}

- (void)setTrackers:(NSArray *)trackers
{
    [self.refreshControl endRefreshing];
    
    // this is the first data - add section
    if( trackers.count > 0 && !_trackers )
    {
        _trackers = trackers;
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        return;
    }
    
    // there is no data - clear section
    if( _trackers.count > 0 &&  trackers.count == 0 )
    {
        _trackers = trackers;
        [self.tableView beginUpdates];
        [self.tableView deleteSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        return;
    }
    
    NSUInteger count = MAX(_trackers.count,trackers.count);
    
    NSMutableArray *indexPathsToAdd = [NSMutableArray array];
    NSMutableArray *indexPathsToRemove = [NSMutableArray array];
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    BOOL needToUpdate = NO;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
    
        TrackerStat *cur = i < _trackers.count ? _trackers[i] : nil;
        TrackerStat *new = i <  trackers.count ?  trackers[i] : nil;
        
        // there is no current element
        // this index is new and should be re
        if( !cur )
        {
            [indexPathsToAdd addObject:path];
            needToUpdate = YES;
        }
        // there is no element in new data
        // this index is stale and should be removed
        else if( !new )
        {
            [indexPathsToRemove addObject:path];
            needToUpdate = YES;
        }
        else
        {
            // compare data
            if( cur.trackerId == new.trackerId )
            {
                // update cell
                TrackerInfoCell *cell = (TrackerInfoCell*)[self.tableView cellForRowAtIndexPath:path];
                if( cell )
                {
                    [self updateCell:cell withData:new];
                }
            }
            // diffrent data, reload data in cell
            else
            {
                [indexPathsToReload addObject:path];
                needToUpdate = YES;
            }
        }
    }
    
    _trackers = trackers;
    
    if( needToUpdate )
    {
        [self.tableView beginUpdates];
        
        if( indexPathsToAdd.count > 0 )
            [self.tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( indexPathsToRemove.count > 0 )
            [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if( indexPathsToReload.count > 0 )
            [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
}

- (void)updateData:(UIRefreshControl*)sender
{
    if( _delegate && [_delegate respondsToSelector:@selector(trackerListNeedUpdateDataForTorrentWithId:)] )
        [_delegate trackerListNeedUpdateDataForTorrentWithId:_torrentId];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString( @"Tracker list", @"" );
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.infoMessage = _trackers.count > 0  ? nil : NSLocalizedString( @"There are no trackers to show", @"");
    return _trackers.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _trackers.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        TrackerStat *info = _trackers[indexPath.row];
        
        // show confirmation dialog
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat: NSLocalizedString( @"Remove tracker:\n%@?", @"" ), info.host]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString( @"Cancel", @"" )
                                             destructiveButtonTitle:NSLocalizedString( @"Remove", @"" )
                                                  otherButtonTitles:nil, nil];
        
        action.dataObject = @(info.trackerId);
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        CGRect r = cell.bounds;
        r.origin.x = r.size.width - 30;
        
        [action showFromRect:r inView:cell animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView setEditing:NO animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView setEditing:NO animated:YES];
    
    if( actionSheet.destructiveButtonIndex == buttonIndex )
    {
        if( _delegate && [_delegate respondsToSelector:@selector(trackerListRemoveTracker:forTorrent:)] )
            [_delegate trackerListRemoveTracker:(int)[actionSheet.dataObject integerValue] forTorrent:_torrentId];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackerStat *info = _trackers[indexPath.row];
    TrackerInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TRACKERINFO forIndexPath:indexPath];
    [self updateCell:cell withData:info];
    return cell;
}

- (void)updateCell:(TrackerInfoCell*)cell withData:(TrackerStat*)info
{
    cell.trackerId = info.trackerId;
    cell.trackerHostLabel.text = info.host;
    cell.lastAnnounceTimeLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Last announce time: %@ %@", @"" ),
                                       info.lastAnnounceTimeString, info.lastAnnounceResult];
    cell.nextAnnounceTimeLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Next announce time: %@", @"" ),
                                       info.nextAnnounceTimeString];
    cell.lastScrapeTimeLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Last scrape-announce time: %@ %@", @"" ),
                                     info.lastScrapeTimeString, info.lastScrapeResult];
    cell.nextScrapeTimeLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Next scrape-announce time: %@", @"" ),
                                     info.nextScrapeTimeString];
    cell.seedersLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Seeders: %i", @"" ), info.seederCount];
    cell.leechersLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Leechers: %i", @"" ), info.leecherCount];
    cell.downloadsLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Downloads: %i", @"" ), info.downloadCount];
    cell.peersLabel.text = [NSString stringWithFormat: NSLocalizedString( @"Peers: %i", @"" ), info.lastAnnouncePeerCount];
}

@end
