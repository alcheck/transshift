//
//  ChooseServerToAddTorrentController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ChooseServerToAddTorrentController.h"
#import "TorrentTitleSectionHeaderView.h"
#import "RPCServerConfigDB.h"
#import "ChooseServerCell.h"
#import "BandwidthPriorityCell.h"
#import "StartImmidiatelyCell.h"
#import "TrackerListCell.h"
#import "FileListController.h"
#import "GlobalConsts.h"

@interface ChooseServerToAddTorrentController ()

@property(nonatomic) TorrentTitleSectionHeaderView *torrentTitleSectionView;

@end

@implementation ChooseServerToAddTorrentController

{
    NSArray                         *_sectionTitles;
    int                             _selectedRow;
    FileListController              *_fileList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Add torrent", @"Choose server controller title");
    
    _sectionTitles = @[  NSLocalizedString(@"Choose server to add torrent", @"Section title"),
                         NSLocalizedString(@"Additional parameters", @"Section title"),
                         NSLocalizedString(@"Tracker list", @"")];
    _selectedRow = 0;
    
    _bandwidthPriority = 1;
    _startImmidiately = YES;
    _rpcConfig = [[RPCServerConfigDB sharedDB].db firstObject];
}

- (void)swithValueChanged:(UISwitch*)sender
{
    _startImmidiately = sender.on;
}

- (void)priorityChanged:(UISegmentedControl*)sender
{
    _bandwidthPriority = (int)sender.selectedSegmentIndex;
}

- (int)bandwidthPriority
{
    return _bandwidthPriority - 1;
}

/// set torrent title
- (void)setTorrentTitle:(NSString *)titleStr andTorrentSize:(NSString *)sizeStr
{
    NSMutableParagraphStyle *alignStyle = [NSMutableParagraphStyle new];
    alignStyle.alignment = NSTextAlignmentCenter;
    
    NSString *sizeRightStr = NSLocalizedString(@"Torrent size: ", @"");
    
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:
                             [NSString stringWithFormat:@"%@\n%@%@", titleStr, sizeRightStr, sizeStr]
                              attributes:@{ NSParagraphStyleAttributeName : alignStyle }];
    
    NSRange titleRange = NSMakeRange(0, titleStr.length );
    NSRange sizeRightRange = NSMakeRange( titleStr.length + 1, sizeRightStr.length );
    NSRange sizeRange = NSMakeRange( titleStr.length + sizeRightStr.length + 1, sizeStr.length );
    
    [s addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:titleRange ];
    [s addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:sizeRightRange ];
    [s addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:sizeRange];
    
    [s addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:titleRange];
    [s addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:sizeRightRange];
    [s addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:sizeRange];
    
    self.torrentTitleSectionView.labelTitle.attributedText = s;
}


- (TorrentTitleSectionHeaderView *)torrentTitleSectionView
{
    if ( !_torrentTitleSectionView )
    {
        _torrentTitleSectionView = [TorrentTitleSectionHeaderView titleSection];
    }
    
    return _torrentTitleSectionView;
}

#pragma mark - TableView Delegate methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
        return self.torrentTitleSectionView;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
        return self.torrentTitleSectionView.bounds.size.height;
    
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _announceList ? _sectionTitles.count : _sectionTitles.count - 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 )
        return [RPCServerConfigDB sharedDB].db.count;

    if( section == 1 )
        return _files ? 3 : 2;
    
    return _announceList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 )
    {
        _selectedRow = (int)indexPath.row;
        _rpcConfig = [RPCServerConfigDB sharedDB].db[indexPath.row];
        [self.tableView reloadData];
    }
    else if( indexPath.section == 1 && indexPath.row == 2 )
    {
        _fileList = instantiateController(CONTROLLER_ID_FILELIST);
        _fileList.fsDir = _files;
        _fileList.title = NSLocalizedString(@"Select files to download", @"UIViewController Title");
        [self.navigationController pushViewController:_fileList animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 )
        return 70;
    else
        return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // choose server to add torrent
    if( indexPath.section == 0 )
    {
        ChooseServerCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_CHOOSESERVER forIndexPath:indexPath];
        RPCServerConfig *config = [RPCServerConfigDB sharedDB].db[indexPath.row];
       
        cell.labelServerName.text = config.name;
        cell.labelServerUrl.text = config.urlString;
        //cell.iconServer.image = [cell.iconServer.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        if( _selectedRow == indexPath.row )
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    // additional paramters
    if( indexPath.section == 1)
    {
        if( indexPath.row == 0)
        {
            BandwidthPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_BANDWIDTHPRIORITY forIndexPath:indexPath];
            cell.segment.selectedSegmentIndex = _bandwidthPriority;
            [cell.segment addTarget:self action:@selector(priorityChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        else if( indexPath.row == 1 )
        {
            StartImmidiatelyCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_STARTIMMIDIATELY forIndexPath:indexPath];
            cell.swith.on = _startImmidiately;
            [cell.swith addTarget:self action:@selector(swithValueChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FILESTODOWNLOAD forIndexPath:indexPath];
            return cell;
        }
    }
    
    
    if( indexPath.section == 2 )
    {
        TrackerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TRACKERLIST forIndexPath:indexPath];
        cell.trackeHostLabel.text = _announceList[indexPath.row];
        return cell;
    }
    
    return nil;
}

@end
