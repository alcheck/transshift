//
//  HeaderView.h
//  test
//
//  Created by Alexey Chechetkin on 06.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterViewFreeSpace : UIView

+ (FooterViewFreeSpace*)view;

- (void)setBoundsFromTableView:(UITableView*)tableView;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic)   UIColor *color;

@end
