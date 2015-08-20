//
//  StatusCategory.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "StatusCategory.h"

@implementation StatusCategoryItem

+ (instancetype)itemWithTitle:(NSString *)title filter:(NSString *)filter
{
    return [[StatusCategoryItem alloc] initWithTitle:title filter:filter];
}

+ (instancetype)itemWithItem:(StatusCategoryItem *)item
{
    StatusCategoryItem *copyItem = [[StatusCategoryItem alloc] initWithTitle:item.title filter:item.filterString];
    copyItem.items = [NSArray arrayWithArray:item.items];
    
    return copyItem;
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

- (int)count
{
    return  _items ? (int)_items.count : 0;
}

- (void)fillItemsFromInfos:(TRInfos*)infos
{
    _items = [infos valueForKey:_filterString];
}


- (TRInfo*)trInfoWithId:(int)torrentId
{
    for( TRInfo* info in _items )
        if( info.trId == torrentId )
            return info;
    
    return nil;
}

@end


@implementation StatusCategory

{
    NSMutableArray *_items;
}

+ (instancetype)categoryWithTitle:(NSString *)title isAlwaysVisible:(BOOL)visible iconType:(IconCloudType)iconType
{
    return [[StatusCategory alloc] initWithTitle:title isAlwaysVisible:visible iconType:iconType];
}

- (instancetype)initWithTitle:(NSString*)title isAlwaysVisible:(BOOL)alwaysVisible iconType:(IconCloudType)iconType
{
    self = [super init];
    
    if( self )
    {
        _title = title;
        _alwaysVisible = alwaysVisible;
        _items = [NSMutableArray array];
        _iconType = iconType;
    }
    
    return self;
}

- (void)addItemWithTitle:(NSString *)title filter:(NSString *)filterString
{
    [_items addObject:[StatusCategoryItem itemWithTitle:title filter:filterString]];
}

- (void)removeEmptyItems
{
    BOOL repeat = YES;
    
    while( repeat )
    {
        repeat = NO;
        for( StatusCategoryItem *item in _items )
        {
            if( item.count == 0 )
            {
                [_items removeObject:item];
                repeat = YES;
                break;
            }
        }
    }
}

- (NSArray *)items
{
    return _items;
}

-(NSMutableArray*)mutableCopyOfNonEmptyItems
{
    if( _items )
    {
        NSMutableArray *resultArray = [NSMutableArray array];
        for( StatusCategoryItem *i in _items )
        {
            if( i.count > 0 )
            {
                [resultArray addObject: [StatusCategoryItem itemWithItem:i] ];
            }
        }
        return resultArray;
    }
    
    return nil;
}

- (StatusCategoryItem *)categoryItemWithTitle:(NSString *)categoryTitle
{
    if( _items )
    {
        for( StatusCategoryItem *i in _items )
        {
            if( [i.title isEqualToString:categoryTitle] )
                return i;
        }
    }
    return nil;
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

- (int)countOfNonEmptyItems
{
    int c = 0;
    for( StatusCategoryItem *item in _items )
    {
        if( item.count > 0 )
        {
            item.index = c;
            c++;
        }
    }
    
    return c;
}

- (StatusCategoryItem *)nonEmptyItemAtIndex:(int)index
{
    int c = 0;
    for( StatusCategoryItem *item in _items )
    {
        if( item.count > 0 )
        {
            if( c == index )
                return item;
            c++;
        }
    }
    
    @throw [NSException exceptionWithName:@"StatusCategory:nonEmptyItemAtIndex" reason:@"there is no element at given index" userInfo:nil];
}

- (BOOL)isVisible
{
    return _alwaysVisible || self.count > 0;
}

@end
