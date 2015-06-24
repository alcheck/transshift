//
//  ServerRequestTimeoutCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_REQUESTTIMEOUT  @"requestTimeoutCell"

@interface ServerRequestTimeoutCell : UITableViewCell

@property (nonatomic) int timeoutValue;

@end
