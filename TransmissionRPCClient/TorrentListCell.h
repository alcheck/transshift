//
//  TorrentListCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_TORRENTLIST @"torrentListCell"

@interface TorrentListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *downloadRate;
@property (weak, nonatomic) IBOutlet UILabel *uploadRate;
@property (weak, nonatomic) IBOutlet UILabel *size;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *progressPercents;
@property (weak, nonatomic) IBOutlet UILabel *peersInfo;

@end
