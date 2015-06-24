//
//  ServerRequestTimeoutCell.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ServerRequestTimeoutCell.h"

@interface ServerRequestTimeoutCell()

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeoutStepper;

@end

@implementation ServerRequestTimeoutCell

- (IBAction)valueChanged:(UIStepper*)sender
{
    self.numLabel.text = [NSString stringWithFormat:@"%02i", (int)sender.value];
}

- (int)timeoutValue
{
    return (int)self.timeoutStepper.value;
}

- (void)setTimeoutValue:(int)timeoutValue
{
    self.timeoutStepper.value = timeoutValue;
    [self valueChanged:self.timeoutStepper];
}

@end
