//
//  CheckBox.h
//  IconTestApp
//
//  Created by Alexey Chechetkin on 13.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckBox : UIControl

@property( nonatomic ) BOOL on;
@property (nonatomic ) UIColor *color;

- (void)setOn:(BOOL)on  animated:(BOOL)animated;

@end
