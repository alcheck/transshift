//
//  SpeedLimitController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 06.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "CommonTableController.h"

#define CONTROLLER_ID_SPEEDLIMIT    @"speedLimitController"
#define CELL_ID_SPEED               @"speedCell"

@protocol SpeedLimitControllerDelegate <NSObject>

@optional - (void)speedLimitControllerSpeedSelectedWithIndex:(int)index;

@end

@interface SpeedLimitController : CommonTableController

@property(weak) id<SpeedLimitControllerDelegate> delegate;
@property(nonatomic) NSArray *speedTitles;
@property(nonatomic) int      selectedSpeed;
@property(nonatomic) BOOL     isDownload;

@end
