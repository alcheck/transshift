//
//  ChooseServerCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_CHOOSESERVER    @"chooseServerCell"

@interface ChooseServerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelServerName;
@property (weak, nonatomic) IBOutlet UILabel *labelServerUrl;
@property (weak, nonatomic) IBOutlet UIImageView *iconServer;

@end
