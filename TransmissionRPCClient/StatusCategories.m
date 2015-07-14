//
//  StatusCategories.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "StatusCategories.h"
#import "TRInfos.h"
#import "GlobalConsts.h"

static NSString* TITLE_ALL      = @"All";
static NSString* TITLE_DOWN     = @"Downloading";
static NSString* TITLE_SEED     = @"Seeding";
static NSString* TITLE_STOP     = @"Stopped";
static NSString* TITLE_ACTIVE   = @"Active";
static NSString* TITLE_CHECK    = @"Checking";
static NSString* TITLE_ERROR    = @"Error";

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
    c = [StatusCategory categoryWithTitle:TITLE_ALL isAlwaysVisible:YES icon:[UIImage iconAll]];
    [c addItemWithTitle:TITLE_DOWN  filter: TRINFOS_KEY_DOWNTORRENTS];
    [c addItemWithTitle:TITLE_SEED  filter: TRINFOS_KEY_SEEDTORRENTS];
    [c addItemWithTitle:TITLE_STOP  filter: TRINFOS_KEY_STOPTORRENTS];
    [c addItemWithTitle:TITLE_CHECK filter: TRINFOS_KEY_CHECKTORRENTS];
    
    c.emptyTitle = @"There are no torrents to show";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:TITLE_ACTIVE isAlwaysVisible:YES icon:[UIImage iconActive]];
    [c addItemWithTitle:TITLE_ACTIVE filter:TRINFOS_KEY_ACTIVETORRENTS];
    c.emptyTitle = @"There are no active torrents to show";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:TITLE_DOWN isAlwaysVisible:NO icon:[UIImage iconDownload]];
    [c addItemWithTitle:TITLE_DOWN filter: TRINFOS_KEY_DOWNTORRENTS];
    c.emptyTitle = @"There are no downloading torrents to show";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:TITLE_SEED isAlwaysVisible:NO icon:[UIImage iconUpload]];
    [c addItemWithTitle:TITLE_SEED filter: TRINFOS_KEY_SEEDTORRENTS];
    c.iconColor = [UIColor seedColor];
    c.emptyTitle = @"There are no seeding torrents to show";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:TITLE_STOP isAlwaysVisible:NO icon:[UIImage iconStop]];
    [c addItemWithTitle:TITLE_STOP filter: TRINFOS_KEY_STOPTORRENTS];
    c.iconColor = [UIColor stopColor];
    c.emptyTitle = @"There are no stopped torrents to show";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:TITLE_CHECK isAlwaysVisible:NO icon:[UIImage iconCheck]];
    [c addItemWithTitle:TITLE_CHECK filter: TRINFOS_KEY_CHECKTORRENTS];
    c.iconColor = [UIColor checkColor];
    c.emptyTitle = @"There are no checking torrents to show";
    [_items addObject:c];
    
    c = [StatusCategory categoryWithTitle:TITLE_ERROR isAlwaysVisible:NO icon:[UIImage iconError]];
    [c addItemWithTitle:TITLE_ERROR filter: TRINFOS_KEY_ERRORTORRENTS];
    c.iconColor = [UIColor errorColor];
    c.emptyTitle = @"There are no error torrents to show";
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
// this method also make reindex of items on the pass (I know, this is SRP violation)
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
