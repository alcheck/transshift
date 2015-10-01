//
//  TorrentListCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconCloud.h"
#import "TorrentListProgressView.h"

#define CELL_ID_TORRENTLIST @"torrentListCell"

@interface TorrentListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *downloadRate;
@property (weak, nonatomic) IBOutlet UILabel *uploadRate;
@property (weak, nonatomic) IBOutlet UILabel *size;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *progressPercents;
@property (weak, nonatomic) IBOutlet UILabel *peersInfo;

@property (weak, nonatomic) IBOutlet TorrentListProgressView *progressBar;

@property (weak, nonatomic) IBOutlet IconCloud *statusIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonStopResume;
@property (nonatomic) int torrentId;
@property (weak, nonatomic) IBOutlet UIImageView *iconRateLimit;
@property (weak, nonatomic) IBOutlet UIImageView *iconRatioLimit;
@property (weak, nonatomic) IBOutlet UIImageView *iconIdleLimit;

@end
