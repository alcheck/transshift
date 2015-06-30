//
//  ServerRefreshTimeoutCell.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ServerRefreshTimeoutCell.h"

@interface ServerRefreshTimeoutCell()

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeoutStepper;

@end

@implementation ServerRefreshTimeoutCell


- (IBAction)changedValue:(UIStepper*)sender
{
    int value = (int)sender.value;
    if( value == 0)
        self.numLabel.text = @"off";
    else
        self.numLabel.text = [NSString stringWithFormat:@"%02i", (int)sender.value];
    
}

- (int)timeoutValue
{
    return (int)self.timeoutStepper.value;
}

- (void)setTimeoutValue:(int)timeoutValue
{
    self.timeoutStepper.value = timeoutValue;
    [self changedValue:self.timeoutStepper];
}

@end
