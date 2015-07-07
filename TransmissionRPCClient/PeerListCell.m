//
//  PeerListCell.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "PeerListCell.h"

@interface PeerListCell()
@end

@implementation PeerListCell

- (void)setIsSecure:(BOOL)isSecure
{
    _isSecure = isSecure;
    
    if (isSecure)
    {
        self.iconSecurity.image = [UIImage imageNamed:@"iconLockLocked15x15"];
    }
    else
    {
        self.iconSecurity.image = [UIImage imageNamed:@"iconLockUnlocked15x15"];
    }
}

- (void)setIsUTPEnabled:(BOOL)isUTPEnabled
{
    _isUTPEnabled = isUTPEnabled;
    
    if( isUTPEnabled )
    {
        self.iconUTP.hidden = NO;
        self.iconUTP.image = [UIImage imageNamed:@"iconUTP15x15"];
    }
    else
    {
        self.iconUTP.hidden = YES;
    }
}

@end
