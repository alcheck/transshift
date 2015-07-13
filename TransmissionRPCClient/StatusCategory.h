//
//  StatusCategory.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRInfos.h"

@interface StatusCategoryItem : NSObject

+ (instancetype)itemWithTitle:(NSString*)title filter:(NSString*)filter;

@property(nonatomic, readonly) NSString *title;               // title of subitem
@property(nonatomic, readonly) NSString *filterString;        // TRInfos KVC property name (filter)
@property(nonatomic, readonly) NSArray  *items;               // array of TRInfo elements
@property(nonatomic, readonly) int      count;                // returns number of elements in items

@end

@interface StatusCategory : NSObject

// convinience init method
+ (instancetype)categoryWithTitle:(NSString*)title isAlwaysVisible:(BOOL)visible iconImageName:(NSString*)iconName;

// add item to the items
- (void)addItemWithTitle:(NSString*)title filter:(NSString*)filterString;

// fills category with array of elements from infos
- (void)fillCategoryFromInfos:(TRInfos*)infos;

@property(nonatomic) NSString *title;           // title of category ("All", "Downloading", "Seeding", "Stopped" ...

@property(nonatomic) BOOL      alwaysVisible;   // visibility of this category (always visible or not)

@property(nonatomic) int       count;           // count of items it category (including all subcategories)

@property(nonatomic) UIImage  *iconImage;       // image of the category

@property(nonatomic,readonly) NSArray  *items;  // array of StatusCategoryItem

@property(nonatomic,readonly) BOOL isVisible;   // returns YES if category is visible (has elements)

@property(nonatomic)          int  index;

@property(nonatomic,weak)     UITableViewCell *cell; // holds UITableViewCell weak reference for later updating

@property(nonatomic)          UIColor *iconColor;

@end
