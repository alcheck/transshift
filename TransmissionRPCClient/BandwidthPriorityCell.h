//
//  BandwidthPriorityCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_BANDWIDTHPRIORITY   @"bandwidthPriorityCell"

@interface BandwidthPriorityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@end
