//
//  ScheduleAltLimitsController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_SCHEDULETIMEDATE  @"scheduleTimeDayController"

@interface ScheduleAltLimitsController : UIViewController

@property(nonatomic) int  daysMask;
@property(nonatomic) int  timeBegin;
@property(nonatomic) int  timeEnd;

@end
