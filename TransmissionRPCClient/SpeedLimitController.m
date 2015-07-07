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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _iconDown = [[UIImage imageNamed:@"iconSpeedDownLimit20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _iconUp = [[UIImage imageNamed:@"iconSpeedUpLimit20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.headerInfoMessage = @"Choose speed";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( _delegate && [_delegate respondsToSelector:@selector(speedLimitControllerSpeedSelectedWithIndex:)] )
        [_delegate speedLimitControllerSpeedSelectedWithIndex:(int)indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _speedTitles ? _speedTitles.count : 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SPEED];
    
    cell.textLabel.text = _speedTitles[indexPath.row];
    cell.accessoryType = _selectedSpeed == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    if( _isDownload && indexPath.row != 0 )
    {
        cell.imageView.image = _iconDown;
        cell.imageView.tintColor = cell.tintColor;
    }
    else if( indexPath.row != 0 )
    {
        cell.imageView.image = _iconUp;
        cell.imageView.tintColor = cell.tintColor;
    }
    
    return cell;
}

@end
