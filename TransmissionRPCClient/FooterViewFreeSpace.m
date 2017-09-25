//
//  HeaderView.m
//  test
//
//  Created by Alexey Chechetkin on 06.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "FooterViewFreeSpace.h"

@implementation FooterViewFreeSpace

{
    CGFloat _originalHeight;
}

+ (FooterViewFreeSpace*)view
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"FooterViewFreeSpace" owner:self options:nil];
    FooterViewFreeSpace *view = [views firstObject];
    
    view.icon.image = [view.icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    view.icon.tintColor = view.label.textColor;
    
    return view;
}

- (void)setColor:(UIColor *)color
{
    _label.textColor = color;
    _icon.tintColor = color;
}

- (void)setBoundsFromTableView:(UITableView *)tableView
{
    CGRect r = self.bounds;
    r.size.width = tableView.bounds.size.width;
    r.size.height = _originalHeight;
    self.bounds = r;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _originalHeight = self.bounds.size.height;
}

@end
