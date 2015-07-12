//
//  StatusCategory.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "StatusCategory.h"

@implementation StatusCategory


+ (instancetype)categoryWithTitle:(NSString *)title items:(NSArray *)items isAlwaysVisible:(BOOL)visible iconImageName:(NSString *)iconName
{
    StatusCategory *category = [[StatusCategory alloc] init];
    
    category.title = title;
    category.items = items;
    category.alwaysVisible = visible;
    category.iconImage = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return category;
}

- (void)fillCategoryFromInfos:(TRInfos *)infos
{
    if( _trInfoArrayName )
    {
        _items = [infos valueForKey:_trInfoArrayName];
    }
}

- (int)count
{
    return _items ? (int)_items.count : 0;
}

- (BOOL)isVisible
{
    return _alwaysVisible || self.count > 0;
}

@end
