//
//  SpeedLimitController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 06.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "SpeedLimitController.h"

@interface SpeedLimitController ()

@end

@implementation SpeedLimitController

{
    UIImage *_iconDown;
    UIImage *_iconUp;
    UIImage *_iconUnlim;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // preload icons
    _iconDown = [[UIImage imageNamed:@"iconSpeedDownLimit20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconUp = [[UIImage imageNamed:@"iconSpeedUpLimit20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconUnlim = [[UIImage imageNamed:@"iconSpeedUnlim20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    //self.headerInfoMessage = _rates.tableTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _rates.selectedRateIndex = (int)indexPath.row;
    
    if( _delegate && [_delegate respondsToSelector:@selector(speedLimitControllerSpeedSelectedWithIndex:)] )
        [_delegate speedLimitControllerSpeedSelectedWithIndex:(int)indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rates ? _rates.count : 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SPEED];
    
    cell.textLabel.text = [_rates titleAtIndex:(int)indexPath.row];
    cell.accessoryType = _rates.selectedRateIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    if( indexPath.row != 0 )
    {
        cell.imageView.image = _isDownload ? _iconDown : _iconUp;
        cell.imageView.tintColor = cell.tintColor;
        cell.imageView.hidden = NO;
    }
    else
    {
        cell.imageView.image = _iconUnlim;
    }
    
    return cell;
}

@end
