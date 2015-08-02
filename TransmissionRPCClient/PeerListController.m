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

@implementation PeerListController

{
    NSArray *_sectionTitles;
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
    [self.refreshControl endRefreshing];
    
    if( _delegate && [_delegate respondsToSelector:@selector(peerListNeedUpdatePeersForTorrentId:)])
        [_delegate peerListNeedUpdatePeersForTorrentId:_torrentId];
}

- (void)setPeers:(NSArray *)peers
{
    _peers = peers;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     // Return the number of sections.
    self.infoMessage =  _peers.count > 0 ? nil : NSLocalizedString(@"There are no peers avalable.", @"");
    
    return _peers.count > 0 ? 2 : 0;
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
    
    return  1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 1 )
        return 174;
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
            return 44;
        
        return 30;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return header row
    if( indexPath.section == 0 && indexPath.row == 0 )
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERLISTHEADERCELL forIndexPath:indexPath];
        return cell;
    }
    
    if( indexPath.section == 0 )
    {
        
        PeerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERLISTCELL forIndexPath:indexPath];
        
        TRPeerInfo *info = self.peers[indexPath.row - 1];
        
        cell.clientLabel.text = info.clientName;
        cell.addressLabel.text = info.ipAddress;
        cell.progressLabel.text = info.progressString;
        cell.flagLabel.text = info.flagString;
        cell.downloadLabel.text = info.rateToClient > 0 ? info.rateToClientString : @"-";
        cell.uploadLabel.text = info.rateToPeer > 0 ?  info.rateToPeerString : @"-";
        cell.isSecure = info.isEncrypted;
        cell.isUTPEnabled = info.isUTP;
        
        return cell;
    }
    
    if( indexPath.section == 1 )
    {
        PeerStatCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERSTAT forIndexPath:indexPath];
        
        cell.labelFromCache.text = [NSString stringWithFormat:
                                    NSLocalizedString( @"From cache: %@", @""), _peerStat.fromChache];
        cell.labelFromDht.text = [NSString stringWithFormat:
                                  NSLocalizedString( @"From DHT: %@", @""), _peerStat.fromDht];
        
        cell.labelFromLpd.text = [NSString stringWithFormat:
                                  NSLocalizedString( @"From LPD: %@", @""), _peerStat.fromLpd];
        
        cell.labelFromPex.text = [NSString stringWithFormat:
                                  NSLocalizedString( @"From PEX: %@", @""), _peerStat.fromPex];
        
        cell.labelFromTracker.text = [NSString stringWithFormat:
                                      NSLocalizedString( @"From tracker: %@", @""), _peerStat.fromTracker];
        
        return cell;
    }
    
    return nil;
}


@end
