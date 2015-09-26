//
//  PeerListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "PeerListController.h"
#import "PeerListCell.h"
#import "PeerStatCell.h"
#import "FlagDescriptionView.h"
#import "IPGeoInfoController.h"
#import "NSObject+DataObject.h"
#import "GlobalConsts.h"
#import "GeoIpConnector.h"

#define ROWHIGHT_PEERINFOHEADER     44
#define ROWHIGHT_PEERINFO           30
#define ROWHIGHT_PEERSTAT           114

#define SECTIONFOOTER_HEIGHT        237

@implementation PeerListController

{
    NSArray *_peers;
    NSArray *_sectionTitles;
    
    TRPeerStat *_peerStat;
    UIPopoverController *_popOver;
    
    BOOL _dataWasSet;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sectionTitles = @[ NSLocalizedString(@"Peers", @""), NSLocalizedString(@"Peers stats", @"") ];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    
    [refreshControl addTarget:self action:@selector(askDelegateToUpdateData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem.title =  NSLocalizedString(@"Info", @"");
}

- (void)askDelegateToUpdateData
{
    //[self.refreshControl endRefreshing];
    
    if( _delegate && [_delegate respondsToSelector:@selector(peerListNeedUpdatePeersForTorrentId:)])
        [_delegate peerListNeedUpdatePeersForTorrentId:_torrentId];
}

- (void)updateWithPeers:(NSArray *)peers andPeerStat:(TRPeerStat *)peerStat
{
    // set flag that tell there is data
    _dataWasSet = YES;
    
    [self.refreshControl endRefreshing];
    
    // this is the first data - add section
    if( peers.count > 0 && _peers.count == 0 )
    {
        _peers = peers;
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        return;
    }
    
    // there is no data - clear section
    if( _peers.count > 0 &&  peers.count == 0 )
    {
        _peers = peers;
        [self.tableView beginUpdates];
        [self.tableView deleteSections: [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        return;
    }
    
    NSUInteger count = MAX(_peers.count,peers.count);
    
    NSMutableArray *indexPathsToAdd = [NSMutableArray array];
    NSMutableArray *indexPathsToRemove = [NSMutableArray array];
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    BOOL needToUpdate = NO;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:(i + 1) inSection:0];
        
        TRPeerInfo *cur = i < _peers.count ? _peers[i] : nil;
        TRPeerInfo *new = i <  peers.count ?  peers[i] : nil;
        
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
            if( [cur.ipAddress isEqualToString: new.ipAddress] )
            {
                // update cell
                PeerListCell *cell = (PeerListCell*)[self.tableView cellForRowAtIndexPath:path];
                if( cell )
                    [self updatePeerListCell:cell withInfo:cur];
            }
            // diffrent data, reload data in cell
            else
            {
                [indexPathsToReload addObject:path];
                needToUpdate = YES;
            }
        }
    }
    
    // store data before update animation
    _peers = peers;
    _peerStat = peerStat;
    
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
    else if( _peers.count == 0 )
    {
        [self.tableView reloadData];
    }
    
    // now we update peer stats
    PeerStatCell *cell = (PeerStatCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if( cell )
        [self updatePeerStatCell:cell witInfo:peerStat];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( !_dataWasSet )
        return 0;
    
     // Return the number of sections.
    self.infoMessage =  _peers.count > 0 ? nil :  NSLocalizedString(@"There are no peers avalable.", @"" );
    
    return _peers.count > 0 ? _sectionTitles.count : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    return  _sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section + 1 for header row
    if( section ==  0 )
        return _peers.count + 1;
    
    // second section (PeerStats) has only one row
    return  1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 1 )
        return ROWHIGHT_PEERSTAT;
    
    if( indexPath.row == 0 )
            return ROWHIGHT_PEERINFOHEADER;
        
    return ROWHIGHT_PEERINFO;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    static UIView *flagsDescriptionView = nil;
    
    if( section == 0 )
    {
        if( !flagsDescriptionView )
            flagsDescriptionView = [FlagDescriptionView flagDescriptionView];
            
        return flagsDescriptionView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if( section == 0 )
        return SECTIONFOOTER_HEIGHT;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  header row
    if( indexPath.section == 0 && indexPath.row == 0 )
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERLISTHEADERCELL forIndexPath:indexPath];
        return cell;
    }
    
    // peer info
    if( indexPath.section == 0 )
    {
        
        PeerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERLISTCELL forIndexPath:indexPath];
        TRPeerInfo *info = _peers[indexPath.row - 1];
        [self updatePeerListCell:cell withInfo:info];
        
        return cell;
    }
    
    // peer stat section
    if( indexPath.section == 1 )
    {
        PeerStatCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERSTAT forIndexPath:indexPath];
        [self updatePeerStatCell:cell witInfo:_peerStat];
        return cell;
    }
    
    return nil;
}

- (void)updatePeerStatCell:(PeerStatCell *)cell witInfo:(TRPeerStat *)info
{
    cell.labelFromCache.text = info.fromChache;
    cell.labelFromDht.text = info.fromDht;
    cell.labelFromLpd.text = info.fromLpd;
    cell.labelFromPex.text = info.fromPex;
    cell.labelFromTracker.text = info.fromTracker;
    cell.labelFromIncoming.text = info.fromIncoming;
}

- (void)updatePeerListCell:(PeerListCell *)cell withInfo:(TRPeerInfo*)info
{
    cell.clientLabel.text = info.clientName;
    cell.addressLabel.text = info.ipAddress;
    cell.progressLabel.text = info.progressString;
    cell.flagLabel.text = info.flagString;
    cell.downloadLabel.text = info.rateToClient > 0 ? info.rateToClientString : @"-";
    cell.uploadLabel.text = info.rateToPeer > 0 ?  info.rateToPeerString : @"-";
    cell.isSecure = info.isEncrypted;
    cell.isUTPEnabled = info.isUTP;
    
    if ( self.splitViewController )
    {
        cell.addressLabel.userInteractionEnabled = YES;
        cell.addressLabel.textColor = self.tableView.tintColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGeoIpController:)];
        tap.dataObject = info;
        info.dataObject = cell;
        [cell.addressLabel addGestureRecognizer:tap];
    }
}

- (void)showGeoIpController:(UIGestureRecognizer *)sender
{
    if( _popOver )
    {
        [_popOver dismissPopoverAnimated:NO];
    }
    
    TRPeerInfo *info = sender.dataObject;

    IPGeoInfoController *c = instantiateController( CONROLLER_ID_IPGEOINFO );
    
    c.ipAddress = info.ipAddress;
    c.title = [NSString stringWithFormat:@"IP %@:%i", info.ipAddress, info.port];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:c];
    
    PeerListCell *cell = info.dataObject;
    
    CGRect rect = cell.addressLabel.frame;
    rect.size.width = 30;
    
    _popOver = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popOver presentPopoverFromRect:rect inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
