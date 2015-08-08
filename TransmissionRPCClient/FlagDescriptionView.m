//
//  FlagDescriptionView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 08.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "FlagDescriptionView.h"

@implementation FlagDescriptionView

+ (UIView *)flagDescriptionView
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"flagsDescription" owner:self options:nil] firstObject];
    
    return view;
}

@end
