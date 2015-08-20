//
//  StatusListCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 01.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconCloud.h"

#define CELL_ID_STATUSLIST      @"statusListCell"

@interface StatusListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet IconCloud *icon;

@end
