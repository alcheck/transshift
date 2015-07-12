//
//  StatusCategory.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 12.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRInfos.h"

@interface StatusCategory : NSObject

+ (instancetype)categoryWithTitle:(NSString*)title items:(NSArray*)items isAlwaysVisible:(BOOL)visible iconImageName:(NSString*)iconName;

@property(nonatomic) NSString *title;           // title of category ("All", "Downloading", "Seeding", "Stopped" ...
@property(nonatomic) BOOL      alwaysVisible;   // visibility of this category (always visible or not)
@property(nonatomic) NSArray  *items;           // torrents in this category
@property(nonatomic) int       count;           // count of items it category
@property(nonatomic) UIImage  *iconImage;       // image of the category

@property(nonatomic) NSString *trInfoArrayName; // KVC name for filter

// fills category with array of elements from infos

- (void)fillCategoryFromInfos:(TRInfos*)infos;

@property(nonatomic,readonly) BOOL isVisible;

@property(nonatomic) int    index;

@property(nonatomic,weak) UITableViewCell *cell;

@property(nonatomic) UIColor *iconColor;

@end
