//
//  ServerListItemCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_SERVERITEM  @"ServerListItemCell"

@protocol ServerListItemCellDelegate <NSObject>

@optional - (void) editButtonTouched:(UISegmentedControl*)button atPath:(NSIndexPath*)indexPath;

@end

@interface ServerListItemCell : UITableViewCell

@property (weak, nonatomic) id<ServerListItemCellDelegate> delegate;
@property (nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end
