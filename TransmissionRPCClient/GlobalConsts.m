//
//  GlobalConsts.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "GlobalConsts.h"

@implementation UIColor (transmissionColors)

+ (UIColor *)errorColor
{
    return [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1];
}

+ (UIColor *)seedColor
{
    return [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];
}

+ (UIColor *)checkColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)stopColor
{
    return [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:1];
}

@end


id instantiateController( NSString *controllerId )
{
    static UIStoryboard* storyboard = nil;
    
    if( !storyboard )
    {
        storyboard = [UIStoryboard storyboardWithName:GLOBAL_CONTROLLERS_STORYBOARD bundle:nil];
    }
    
    
    return [storyboard instantiateViewControllerWithIdentifier:controllerId];
}