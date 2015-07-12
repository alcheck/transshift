//
//  StatusCategories.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "StatusCategories.h"
#import "TRInfos.h"

@interface StatusCategories()

@end

@implementation StatusCategories

{
    NSMutableArray *_items;
    
    NSMutableArray  *_indexesBecomeUnvisible;
    NSMutableArray  *_indexesBecomeVisible;
}

- (instancetype)init
{
    // initialize categories
    self = [super init];
    
    if( !self )
        return self;
    
    // init all categories that could be in status list
    _items = [NSMutableArray array];
    
    StatusCategory *c;
    
    // Fill categories
    c = [StatusCategory categoryWithTitle:@"All" items:nil isAlwaysVisible:YES iconImageName:@"allIcon"];
    c.trInfoArrayName = @"allTorrents";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:@"Active" items:nil isAlwaysVisible:NO iconImageName:@"activeIcon"];
    c.trInfoArrayName = @"activeTorrents";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:@"Downloading" items:nil isAlwaysVisible:NO iconImageName:@"downloadIcon"];
    c.trInfoArrayName = @"downloadingTorrents";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:@"Seeding" items:nil isAlwaysVisible:NO iconImageName:@"uploadIcon"];
    c.trInfoArrayName = @"seedingTorrents";
    c.iconColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:@"Stopped" items:nil isAlwaysVisible:NO iconImageName:@"stopIcon"];
    c.trInfoArrayName = @"stoppedTorrents";
    c.iconColor = [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:1];
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:@"Checking" items:nil isAlwaysVisible:NO iconImageName:@"checkIcon"];
    c.trInfoArrayName = @"checkingTorrents";
    c.iconColor = [UIColor lightGrayColor];
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:@"Error" items:nil isAlwaysVisible:NO iconImageName:@"iconErrorTorrent40x40"];
    c.trInfoArrayName = @"errorTorrents";
    c.iconColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1];
    [_items addObject:c];
                       
    return self;
}

// update all categories with new info
- (void)updateInfos:(TRInfos *)infos
{
    for( StatusCategory *c in _items )
    {
        [c fillCategoryFromInfos:infos];
    }
}

// update visible items and return array of indexes
// of items that changed to unvisible
- (NSArray*)updateForDeleteWithInfos:(TRInfos *)infos
{
    _indexesBecomeUnvisible = [NSMutableArray array];
    
    for( StatusCategory *c in _items )
    {
        if( c.isVisible )
        {
            // updating this visible item
            [c fillCategoryFromInfos:infos];
            
            // now watch if this item is changed
            if( !c.isVisible )
            {
                [_indexesBecomeUnvisible addObject:@(c.index)];
            }
        }
    }
    
    return _indexesBecomeUnvisible;
}

// update unvisible items and return array of indexes
// of items that changed to visible
- (NSArray*)updateForInsertWithInfos:(TRInfos*)infos
{
    _indexesBecomeVisible = [NSMutableArray array];
    
    int i = 0;
    for( StatusCategory *c in _items )
    {
        if( c.isVisible )
        {
            //c.index = i;
            i++;
        }
        
        if( !c.isVisible )
        {
            [c fillCategoryFromInfos:infos];
            
            if( c.isVisible )
            {
                [_indexesBecomeVisible addObject:@(i)];
                //c.index = i;
                i++;
            }
        }
    }
    
    return _indexesBecomeVisible;
}


// returns visible category at given index or nil
- (StatusCategory *)categoryAtIndex:(int)index
{
    int i = 0;
    for( StatusCategory *c in _items )
    {
        if( c.isVisible )
        {
            if( index == i )
                return c;
            
            i++;
        }
    }
    
    return nil;
}

// returns number of visible items
// the visible item is the item that has visibility flag is ON or count of elements > 0
- (int)countOfVisible
{
    int i = 0;
    for( StatusCategory *c in _items )
    {
        if( c.isVisible )
        {
            c.index = i;        // store current index
            i++;
        }
    }
    
    return i;
}


@end
