//
//  StatusCategory.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "StatusCategory.h"

@implementation StatusCategoryItem

{
    NSArray *_items;
}

+ (instancetype)itemWithTitle:(NSString *)title filter:(NSString *)filter
{
    return [[StatusCategoryItem alloc] initWithTitle:title filter:filter];
}

- (instancetype)initWithTitle:(NSString*)title filter:(NSString*)filter
{
    self = [super init];
    
    if( self )
    {
        _filterString = filter;
        _title = title;
    }
    
    return self;
}

- (NSArray *)items
{
    return _items;
}

- (int)count
{
    return  _items ? (int)_items.count : 0;
}

- (void)fillItemsFromInfos:(TRInfos*)infos
{
    _items = [infos valueForKey:_filterString];
}

@end


@implementation StatusCategory

{
    NSMutableArray *_items;
}

+ (instancetype)categoryWithTitle:(NSString *)title isAlwaysVisible:(BOOL)visible iconImageName:(NSString *)iconName
{
    return [[StatusCategory alloc] initWithTitle:title isAlwaysVisible:visible iconImageName:iconName];
}

- (instancetype)initWithTitle:(NSString*)title isAlwaysVisible:(BOOL)alwaysVisible iconImageName:(NSString*)iconImageName
{
    self = [super init];
    
    if( self )
    {
        _title = title;
        _alwaysVisible = alwaysVisible;
        _items = [NSMutableArray array];
        _iconImage = [[UIImage imageNamed:iconImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    return self;
}

- (void)addItemWithTitle:(NSString *)title filter:(NSString *)filterString
{
    [_items addObject:[StatusCategoryItem itemWithTitle:title filter:filterString]];
}

- (void)fillCategoryFromInfos:(TRInfos *)infos
{
    for( StatusCategoryItem *item in _items )
    {
        [item fillItemsFromInfos:infos];
    }
}

- (int)count
{
    NSInteger c = 0;
    for( StatusCategoryItem *item in _items )
            c += item.count;
    
    return (int)c;
}

- (BOOL)isVisible
{
    return _alwaysVisible || self.count > 0;
}

@end
