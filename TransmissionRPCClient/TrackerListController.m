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

{
}

- (void)viewDidLoad
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateData:) forControlEvents:UIControlEventValueChanged];
}

- (void)setTrackers:(NSArray *)trackers
{
    self.infoMessage = nil;
    _trackers = trackers;
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)updateData:(UIRefreshControl*)sender
{
    if( _delegate && [_delegate respondsToSelector:@selector(trackerListNeedUpdateDataForTorrentWithId:)] )
        [_delegate trackerListNeedUpdateDataForTorrentWithId:_torrentId];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Tracker List", @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( _trackers && _trackers.count > 0 )
        return 1;
    
    self.infoMessage = NSLocalizedString(@"There are no trackers to show", @"");
    return 0;
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
            [_delegate trackerListRemoveTracker:[actionSheet.dataObject integerValue] forTorrent:_torrentId];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackerStat *info = _trackers[indexPath.row];
    
    TrackerInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TRACKERINFO forIndexPath:indexPath];
    
    cell.trackerHostLabel.text = info.host;
    cell.lastAnnounceTimeLabel.text = [NSString stringWithFormat:@"Last announce time: %@ %@", info.lastAnnounceTimeString, info.lastAnnounceResult];
    cell.nextAnnounceTimeLabel.text = [NSString stringWithFormat:@"Next announce time: %@", info.nextAnnounceTimeString];
    cell.lastScrapeTimeLabel.text = [NSString stringWithFormat:@"Last scrape-announce time: %@ %@", info.lastScrapeTimeString, info.lastScrapeResult];
    cell.nextScrapeTimeLabel.text = [NSString stringWithFormat:@"Next scrape-announce time: %@", info.nextScrapeTimeString];
    cell.seedersLabel.text = [NSString stringWithFormat:@"Seeders: %i", info.seederCount];
    cell.leechersLabel.text = [NSString stringWithFormat:@"Leechers: %i", info.leecherCount];
    cell.downloadsLabel.text = [NSString stringWithFormat:@"Downloads: %i", info.downloadCount];
    cell.peersLabel.text = [NSString stringWithFormat:@"Peers: %i", info.lastAnnouncePeerCount];
    
    return cell;
}

@end
