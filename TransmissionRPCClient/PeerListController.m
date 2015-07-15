//
//  PeerListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "PeerListController.h"
#import "PeerListCell.h"

@interface PeerListController ()

@property(nonatomic) NSString *backgroundTitle;

@end

@implementation PeerListController

{
    UILabel *_backgroundLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)setBackgroundTitle:(NSString *)backgroundTitle
{
    if( !backgroundTitle )
        self.tableView.backgroundView = nil;
    
    if( !_backgroundLabel )
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:19];
        label.numberOfLines = 0;
        _backgroundLabel = label;
    }
    
    _backgroundLabel.text = backgroundTitle;
    self.tableView.backgroundView = _backgroundLabel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( _peers && _peers.count > 0 )
    {
        self.backgroundTitle = nil;
        return 1;
    }
    
    // Return the number of sections.
    self.backgroundTitle =  NSLocalizedString(@"There are no peers avalable.", @"PeerList background message");
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    return  NSLocalizedString(@"Peers", @"");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _peers.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_PEERLISTHEADERCELL forIndexPath:indexPath];
        return cell;
    }
    
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


@end
