//
//  TrackerInfoCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_TRACKERINFO @"trackerInfoCell"

@interface TrackerInfoCell : UITableViewCell

@property (nonatomic) int trackerId;

@property (weak, nonatomic) IBOutlet UILabel *trackerHostLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastAnnounceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextAnnounceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastScrapeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextScrapeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *seedersLabel;
@property (weak, nonatomic) IBOutlet UILabel *leechersLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadsLabel;
@property (weak, nonatomic) IBOutlet UILabel *peersLabel;

@end
