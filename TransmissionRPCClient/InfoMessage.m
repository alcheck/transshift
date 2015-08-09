//
//  InfoMessage.m
//  test
//
//  Created by Alexey Chechetkin on 09.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "InfoMessage.h"
#import "GlobalConsts.h"

#define INFO_MESSAGE_TOPMARGIN          20
#define INFO_MESSAGE_CORNERRADIUS       3

#define INFO_MESSAGE_DEFAULTHIDETIMEOUT 2

#define INFO_MESSAGE_ICONCHECK          @"iconCheck20x20"
#define INFO_MESSAGE_ICONEXCLAMATION    @"iconExclamation20x20"
#define INFO_MESSAGE_BUNDLENAME         @"InfoMessage"

@interface InfoMessage()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property(nonatomic) UIImage *iconInfo;
@property(nonatomic) UIImage *iconError;

@end

@implementation InfoMessage

{
    int showTimeDelay;
}

+ (InfoMessage *)infoMessageWithSize:(CGSize)sz
{
    static UIImage *iconCheck = nil;
    static UIImage *iconExclamation = nil;
    
    if( !iconCheck )
    {
        iconCheck = [[UIImage imageNamed:INFO_MESSAGE_ICONCHECK]
                     imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        iconExclamation = [[UIImage imageNamed:INFO_MESSAGE_ICONEXCLAMATION]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
 
    InfoMessage *msg = [[[NSBundle mainBundle] loadNibNamed:INFO_MESSAGE_BUNDLENAME owner:self options:nil] firstObject];
    msg.frame = CGRectMake(0, 0, sz.width, sz.height);
    
    msg.iconInfo = iconCheck;
    msg.iconError = iconExclamation;
    
    msg.layer.cornerRadius = INFO_MESSAGE_CORNERRADIUS;
    msg.layer.shadowColor = [UIColor blackColor].CGColor;
    msg.layer.shadowOpacity = 0.2;
    msg.layer.shadowOffset = CGSizeMake(3, 3);
    
    return msg;
}

- (void)showInfo:(NSString *)infoStr fromView:(UIView *)parentView
{
    showTimeDelay = INFO_MESSAGE_DEFAULTHIDETIMEOUT;
    [self setText:infoStr];
    
    self.label.textColor = [UIColor whiteColor];
    self.icon.image = _iconInfo;
    self.backgroundColor = [UIColor grayColor];
    self.icon.tintColor =  [UIColor whiteColor];
    
    
    [self showFromView:parentView];
}

- (void)showErrorInfo:(NSString *)errStr fromView:(UIView *)parentView
{
    showTimeDelay = INFO_MESSAGE_DEFAULTHIDETIMEOUT * 1.3;
    
    [self setText:errStr];
    
    self.label.textColor = [UIColor whiteColor];
    self.icon.image = _iconError;
    self.backgroundColor = [UIColor errorColor];
    self.icon.tintColor = [UIColor whiteColor];
    
    [self showFromView:parentView];
}

- (void)setText:(NSString*)text
{
    self.label.text = text;
    [self layoutIfNeeded];
    
    CGSize sz = self.label.bounds.size;
    if( self.bounds.size.height <= (sz.height - 16) )
    {
        // change window bounds
        CGRect r = self.bounds;
        r.size.height = sz.height + 16;
        self.bounds = r;
        [self setNeedsLayout];
    }
}

- (void)showFromView:(UIView *)parentView
{
    CGPoint p = CGPointMake(parentView.center.x, -self.bounds.size.height/2);
    
    self.center = p;
    
    // animiate
    [parentView addSubview:self];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:
    ^{
        CGPoint pEnd = p;
        pEnd.y = self.bounds.size.height/2 + INFO_MESSAGE_TOPMARGIN;
        self.center = pEnd;
        
    } completion:^(BOOL finished)
    {
        // hide message after delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(showTimeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            
            [UIView animateWithDuration:0.7 animations:^
            {
                self.center = p;
            } completion:^(BOOL finished)
            {
                [self removeFromSuperview];
            }];
           
        });
    }];
}

@end
