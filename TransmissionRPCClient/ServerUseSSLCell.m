//
//  ServerUseSSLCell.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ServerUseSSLCell.h"

@interface ServerUseSSLCell()

@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;

@end

@implementation ServerUseSSLCell

- (BOOL)status
{
    return self.statusSwitch.on;
}

- (void)setStatus:(BOOL)status
{
    self.statusSwitch.on = status;
}

@end
