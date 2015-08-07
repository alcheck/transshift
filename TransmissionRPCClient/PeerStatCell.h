//
//  PeerStatCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 03.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_PEERSTAT    @"peerStatCell"

@interface PeerStatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelFromCache;
@property (weak, nonatomic) IBOutlet UILabel *labelFromDht;
@property (weak, nonatomic) IBOutlet UILabel *labelFromPex;
@property (weak, nonatomic) IBOutlet UILabel *labelFromLpd;
@property (weak, nonatomic) IBOutlet UILabel *labelFromTracker;
@property (weak, nonatomic) IBOutlet UILabel *labelFromIncoming;

@end
