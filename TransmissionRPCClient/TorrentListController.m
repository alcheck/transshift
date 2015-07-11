//
//  TorrentListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListController.h"
#import "TorrentListCell.h"

#define ICON_DOWNLOAD   @"downloadIcon"
#define ICON_UPLOAD     @"uploadIcon"
#define ICON_STOP       @"stopIcon"
#define ICON_CHECK      @"checkIcon"
#define ICON_ERROR      @"iconErrorTorrent40x40"

@interface TorrentListController () <UIActionSheetDelegate>

@end

@implementation TorrentListController

{
    UILabel *_backgroundLabel;
    NSMutableArray *_sectionTitles;
    NSMutableArray *_sectionTorrents;
    TorrentListCell *_editCell;
    
    NSDictionary*   _statusIconImages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareData];
    
    _statusIconImages = @{ ICON_DOWNLOAD :  [[UIImage imageNamed:ICON_DOWNLOAD] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                           ICON_STOP :      [[UIImage imageNamed:ICON_STOP] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                           ICON_UPLOAD :    [[UIImage imageNamed:ICON_UPLOAD] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                           ICON_CHECK :     [[UIImage imageNamed:ICON_CHECK] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                           ICON_ERROR :     [[UIImage imageNamed:ICON_ERROR] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]};
}


- (void)setTorrents:(TRInfos *)torrents
{
    _torrents = torrents;
    self.errorMessage = nil;
    
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
    
    if( _filterOptions & TRStatusOptionsActive )
    {
        NSArray *arr = _torrents.activeTorrents;
        if( arr.count > 0 )
        {
            [_sectionTitles addObject:STATUS_ROW_ACTIVE];
            [_sectionTorrents addObject:arr];
        }
    }
    
    if( _filterOptions & TRStatusOptionsError )
    {
        NSArray *arr = _torrents.errorTorrents;
        if( arr.count > 0 )
        {
            [_sectionTitles addObject:STATUS_ROW_ERROR];
            [_sectionTorrents addObject:arr];
        }
    }
}

#pragma mark - UISplitViewControllerDelegate methods

- (void)setPopoverButtonTitle:(NSString *)popoverButtonTitle
{
    _popoverButtonTitle = popoverButtonTitle;
    if( self.splitViewController && self.navigationItem.leftBarButtonItem )
    {
       [self.navigationItem.leftBarButtonItem setTitle:popoverButtonTitle];
    }
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    //NSLog(@"TorrentListControllerWillHideForPopover: %@", self.popoverButtonTitle);
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // check how many sections do we have
    if ( _sectionTitles && _sectionTitles.count > 0 )
    {
        self.infoMessage = nil;
        return _sectionTitles.count;
    }
    
    self.infoMessage = @"There are no torrents to show.";
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
        cell.downloadRate.text = [NSString stringWithFormat:@"↑UL: %@/s", info.uploadRateString];
        cell.size.text = [NSString stringWithFormat:@"%@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.uploadedEverString, info.uploadRatio];
        cell.statusIcon.image = _statusIconImages[ICON_UPLOAD];
    }
    else if( info.isDownloading )
    {
        detailInfo = [NSString stringWithFormat:@"Downloading from %i of %i peers, ETA: %@", info.peersSendingToUs, info.peersConnected, info.etaTimeString ];
        cell.downloadRate.text = [NSString stringWithFormat:@"↓DL: %@/s", info.downloadRateString];
        cell.uploadRate.text = [NSString stringWithFormat:@"↑UL: %@/s", info.uploadRateString];
        cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.totalSizeString ];
        cell.statusIcon.image = _statusIconImages[ICON_DOWNLOAD];
    }
    else if( info.isStopped )
    {
        detailInfo = @"Paused";
        progressBarColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.0 alpha:1];
        cell.downloadRate.text = @"no activity";
        //cell.downloadRate.textColor = [UIColor lightGrayColor];
        cell.size.text = [NSString stringWithFormat:@"%@ of %@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.totalSizeString, info.uploadedEverString, info.uploadRatio];
        cell.statusIcon.image = _statusIconImages[ICON_STOP];

    }
    else if( info.isChecking )
    {
        detailInfo = @"Checking";
        progressBarColor = [UIColor colorWithRed:0 green:0 blue:0.7 alpha:1];
        cell.progressBar.progress = info.recheckProgress;
        cell.progressPercents.text = info.recheckProgressString;
        cell.size.text = [NSString stringWithFormat:@"%@ of %@", info.downloadedSizeString, info.downloadedEverString];
        cell.statusIcon.image = _statusIconImages[ICON_CHECK];
    }
    
    // because error torrent has native status as "stopped" we
    // should handle this case aside of common "if"
    if( info.isError )
    {
        detailInfo = [NSString stringWithFormat:@"Error: %@", info.errorString]; //@"Paused due to some error";
        progressBarColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1];
        //cell.downloadRate.text = [NSString stringWithFormat:@"Error[%i]", info.errorNumber];
        //cell.downloadRate.textColor = [UIColor lightGrayColor];
        cell.size.text = [NSString stringWithFormat:@"%@ of %@, uploaded %@ (Ratio %0.2f)", info.downloadedSizeString, info.totalSizeString, info.uploadedEverString, info.uploadRatio];
        cell.statusIcon.image = _statusIconImages[ICON_ERROR];
    }
    
    cell.progressBar.tintColor = progressBarColor;
    cell.peersInfo.text = detailInfo;
    cell.statusIcon.tintColor = progressBarColor;
    
    return cell;
}

@end
