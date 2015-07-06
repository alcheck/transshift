//
//  GlobalConsts.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "GlobalConsts.h"


id instantiateController( NSString *controllerId )
{
    static UIStoryboard* storyboard = nil;
    
    if( !storyboard )
    {
        storyboard = [UIStoryboard storyboardWithName:GLOBAL_CONTROLLERS_STORYBOARD bundle:nil];
    }
    
    
    return [storyboard instantiateViewControllerWithIdentifier:controllerId];
}