//
//  StatusCategory.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRInfos.h"
#import "IconCloud.h"

/*!
     StatusCategoryItem holds an array of TRInfo objects and
     also has a group name for it
 */
@interface StatusCategoryItem : NSObject

/*!
    Convinience class initializer
    @param title - the title of this category item
    @param filter - filter KVC string for update from TRInfos
 */
+ (instancetype)itemWithTitle:(NSString*)title filter:(NSString*)filter;

/*!
    Returns new object as a deep copy of given
    @param item - to copy from
    @return StatusCategoryItem with deep copy of item
 */
+ (instancetype)itemWithItem:(StatusCategoryItem*)item;

/**
  Searches and returns TRInfo for given torrent id
  @param torrentId id for searching  info
  @return TRInfo object or nil if info was not found
 */
- (TRInfo*)trInfoWithId:(int)torrentId;

/// Holds title of category
@property(nonatomic, readonly) NSString         *title;

/// Filter string - KVC property name of TRInfos filtered arrays
@property(nonatomic, readonly) NSString         *filterString;

/// Array of TRInfo objects
@property(nonatomic          ) NSArray          *items;

/// Count of TRInfo objects in category
@property(nonatomic, readonly) int              count;

/// Non emtpy index of this object in upper StatusCategory
@property(nonatomic)           int              index;

@end


/// StatusCategory - holds an array of StatusCategoryItem objects (as a subcategory)

@interface StatusCategory : NSObject

/// convinience init method
+ (instancetype)categoryWithTitle:(NSString*)title isAlwaysVisible:(BOOL)visible iconType:(IconCloudType)iconType;

/// add item to the items
- (void)addItemWithTitle:(NSString*)title filter:(NSString*)filterString;

/// Fills category with array of elements from infos
- (void)fillCategoryFromInfos:(TRInfos*)infos;

- (StatusCategoryItem*)nonEmptyItemAtIndex:(int)index;

- (void)removeEmptyItems;

/**
    Returns mutable copy of StatusCategoryItem items
    @return NSMutableArray object filled with  non empty StatusCategoryItem objects
 */
- (NSMutableArray*)mutableCopyOfNonEmptyItems;

/**
    Get the StatusCategoryItem by its title
    @param categoryTitle - title of StatusCategoryItem to return
    @return StatusCategoryItem or nil if such a item was not found
 */
- (StatusCategoryItem*)categoryItemWithTitle:(NSString*)categoryTitle;

@property(nonatomic) NSString       *title;          // title of category ("All", "Downloading", "Seeding", "Stopped" ...
@property(nonatomic) NSString       *emptyTitle;     // title of category when there are no items in it
@property(nonatomic) BOOL           alwaysVisible;   // visibility of this category (always visible or not)
@property(nonatomic,readonly) int   count;           // count of items it category (including all subcategories)
@property(nonatomic) IconCloudType  iconType;       // image of the category

@property(nonatomic,readonly) NSArray  *items;  // array of StatusCategoryItem

@property(nonatomic,readonly) BOOL isVisible;   // returns YES if category is visible (has elements)

@property(nonatomic)          int  index;

@property(nonatomic,weak)     UITableViewCell *cell; // holds UITableViewCell weak reference for later updating

@property(nonatomic)          UIColor *iconColor;

@property(nonatomic,readonly) int countOfNonEmptyItems;

@end
