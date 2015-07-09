//
//  InfoMessage.h
//  test
//
//  Created by Alexey Chechetkin on 09.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoMessage : UIView

+ (InfoMessage*)infoMessageWithSize:(CGSize)size;

- (void)showFromView:(UIView*)parentView;

- (void)showInfo:(NSString*)infoStr fromView:(UIView*)parentView;
- (void)showErrorInfo:(NSString*)errStr fromView:(UIView*)parentView;

@end
