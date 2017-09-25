//
//  WaitViewController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 21.04.16.
//  Copyright © 2016 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_WAIT  @"waitViewController"

@interface WaitViewController : UIViewController

/// holds status text
@property(nonatomic) NSString *statusText;

/// holds timeout value if 0 - timeout is disabled
@property(nonatomic) NSTimeInterval activityTimeout;

/// stops animating activity indicator
/// hides indicator and shows error icon
- (void)stopActivity;

@end
