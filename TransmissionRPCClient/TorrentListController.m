//
//  TorrentListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListController.h"
#import "TorrentListCell.h"

@interface TorrentListController () 

@end

@implementation TorrentListController

{
    UILabel *_backgroundLabel;
    NSMutableArray *_sectionTitles;
    NSMutableArray *_sectionTorrents;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareData];
}

// show background message for this tableview
// when message is shown, all data is cleared
- (void)setBackgroundTitle:(NSString *)backgroundTitle
{
    if( !_backgroundLabel )
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:19];
        label.numberOfLines = 0;
        _backgroundLabel = label;
        self.tableView.backgroundView = _backgroundLabel;
    }
    
    _backgroundLabel.text = backgroundTitle;
}

- (void)setTorrents:(TRInfos *)torrents
{
    _torrents = torrents;
    
    [self prepareData];
    [self.tableView reloadData];
}


- (void)setFilterOptions:(TRStatusOptions)filterOptions
{
    _filterOptions = filterOptions;
    
    [self prepareData];
    [self.tableView reloadData];
}

- (void)prepareData
{
    // init data for rows
    _sectionTitles = [NSMutableArray array];
    _sectionTorrents = [NSMutableArray array];

    if( !_torrents )
        return;
    
    if( _filterOptions & TRStatusOptionsDownload )
    {
        NSArray *arr = _torrents.downloadingTorrents;
        if( arr.count > 0 )
        {
            [_sectionTitles addObject:STATUS_ROW_DOWNLOAD];
            [_sectionTorrents addObject:arr];
        }
    }
    
    if( _filterOptions & TRStatusOptionsSeed )
    {
        NSArray *arr = _torrents.seedingTorrents;
        if( arr.count > 0 )
        {
            [_sectionTitles addObject:STATUS_ROW_SEED];
            [_sectionTorrents addObject:arr];
        }
    }
    
    if( _filterOptions & TRStatusOptionsStop )
    {
        NSArray *arr = _torrents.stoppedTorrents;
        if( arr.count > 0 )
        {
            [_sectionTitles addObject:STATUS_ROW_STOP];
            [_sectionTorrents addObject:arr];
        }
    }
    
    if( _filterOptions & TRStatusOptionsCheck )
    {
        NSArray *arr = _torrents.checkingTorrents;
        if( arr.count > 0 )
        {
            [_sectionTitles addObject:STATUS_ROW_CHECK];
            [_sectionTorrents addObject:arr];
        }
    }
}

#pragma mark - UISplitViewControllerDelegate methods

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

#pragma mark - Table view data source

// torrent is selected, signal to delegate with
// correspondend torrent id
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // getting torrent id from selected cell
    if( _delegate && [_delegate respondsToSelector:@selector(showDetailedInfoForTorrentWithId:)])
    {
        TorrentListCell *cell = (TorrentListCell*)[tableView cellForRowAtIndexPath:indexPath];
        [_delegate showDetailedInfoForTorrentWithId:cell.torrentId];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // check how many sections do we have
    if ( _sectionTitles )
    {
        tableView.backgroundView = nil;
        return _sectionTitles.count;
    }
    
    self.backgroundTitle = @"There are no torrents to show.";
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( _sectionTitles )
        return ((NSArray *)_sectionTorrents[section]).count;
    
    return 0;
}

// returns configured cell for torrent
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TorrentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TORRENTLIST forIndexPath:indexPath];
    
    TRInfo *info = _sectionTorrents[indexPath.section][indexPath.row];
    
    cell.name.text = info.name;
    cell.progressPercents.text = info.percentsDoneString;
    cell.progressBar.progress = info.percentsDone;
    cell.torrentId = info.trId;
    cell.downloadRate.text = @"";
    cell.uploadRate.text = @"";
    //cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.totalSizeString ];
    cell.progressBar.trackTintColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    
    UIColor *progressBarColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    NSString *detailInfo = @"";
    
    if ( info.isSeeding )
    {
        progressBarColor = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:1.0];
        detailInfo = [NSString stringWithFormat:@"Seeding to %i of %i peers", info.peersGettingFromUs, info.peersConnected ];
        cell.downloadRate.text = [NSString stringWithFormat:@"UL: %@/s", info.uploadRateString];
        cell.size.text = [NSString stringWithFormat:@"%@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.uploadedEverString, info.uploadRatio];
    }
    else if( info.isDownloading )
    {
        detailInfo = [NSString stringWithFormat:@"Downloading from %i of %i peers", info.peersSendingToUs, info.peersConnected ];
        cell.downloadRate.text = [NSString stringWithFormat:@"DL: %@/s", info.downloadRateString];
        cell.uploadRate.text = [NSString stringWithFormat:@"UL: %@/s", info.uploadRateString];
        cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.totalSizeString ];
    }
    else if( info.isStopped )
    {
        detailInfo = @"Paused";
        progressBarColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        cell.size.text = [NSString stringWithFormat:@"%@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.uploadedEverString, info.uploadRatio];
    }
    else if( info.isChecking )
    {
        detailInfo = @"Checking";
        progressBarColor = [UIColor colorWithRed:0 green:0 blue:0.7 alpha:1];
        cell.progressBar.progress = info.recheckProgress;
        cell.progressPercents.text = info.recheckProgressString;
        cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.downloadedEverString];
    }
    
    cell.progressBar.tintColor = progressBarColor;
    cell.peersInfo.text = detailInfo;
    
    return cell;
}

@end
