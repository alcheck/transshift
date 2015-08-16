//
//  CheckBox.m
//  IconTestApp
//
//  Created by Alexey Chechetkin on 13.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "CheckBox.h"

#define CHECKBOX_FILLALPHA          0.03
#define ANIMATION_SCALEFACTOR       1.3
#define DISABLED_COLOR              [UIColor grayColor]
#define LAYER_FRAME                 CGRectMake( 0, 0, 29, 29 )

@implementation CheckBox

{
    CAShapeLayer *_layerBox;
    CAShapeLayer *_layerCheck;
    
    UITapGestureRecognizer *_tapRecognizer;
    
    UIColor *_fillColor;
    
    BOOL _animationEnabled;
}

- (void)createLayers
{
    _fillColor = [_color colorWithAlphaComponent:CHECKBOX_FILLALPHA];
    
    _layerBox = [CAShapeLayer layer];
    _layerBox.strokeColor = _color.CGColor;
    //_layerBox.fillColor = [UIColor clearColor].CGColor;
    _layerBox.fillColor = _fillColor.CGColor;
    _layerBox.lineCap = kCALineCapRound;
    _layerBox.lineWidth = 1.0;
    _layerBox.contentsScale = [UIScreen mainScreen].scale;
    _layerBox.frame = LAYER_FRAME;
    
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 1.5, 26, 26) cornerRadius: 5];
    
    _layerBox.path = rectPath.CGPath;
    
    _layerCheck = [CAShapeLayer layer];
    _layerCheck.strokeColor = _color.CGColor;
    _layerCheck.fillColor = [UIColor clearColor].CGColor;
    _layerCheck.lineCap = kCALineCapRound;
    _layerCheck.lineJoin = kCALineJoinRound;
    _layerCheck.lineWidth = 3.5;
    _layerCheck.contentsScale = [UIScreen mainScreen].scale;
//    _layerCheck.shadowColor = [UIColor blackColor].CGColor;
//    _layerCheck.shadowOpacity = 0.3;
//    _layerCheck.shadowOffset = CGSizeMake(1.1, 1.1);
//    _layerCheck.shadowRadius = 1.0;
    _layerCheck.frame = LAYER_FRAME;
    
    UIBezierPath* checkPath = UIBezierPath.bezierPath;
    [checkPath moveToPoint: CGPointMake(7, 16)];
    [checkPath addLineToPoint: CGPointMake(14.5, 21.5)];
    [checkPath addLineToPoint: CGPointMake(24, 2)];
    
    _layerCheck.path = checkPath.CGPath;
    
    [self.layer addSublayer:_layerBox];
    [self.layer addSublayer:_layerCheck];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCheckbox)];
    
    [self addGestureRecognizer:_tapRecognizer];    
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    _tapRecognizer.enabled = self.enabled;
    
    _layerCheck.strokeColor = self.enabled ? _color.CGColor : [_color colorWithAlphaComponent:0.5].CGColor ;//DISABLED_COLOR.CGColor;
    _layerBox.strokeColor = self.enabled ? _color.CGColor : [_color colorWithAlphaComponent:0.5].CGColor ;//DISABLED_COLOR.CGColor;
    _layerBox.fillColor = self.enabled ? _fillColor.CGColor : [_color colorWithAlphaComponent:CHECKBOX_FILLALPHA].CGColor;
}

- (void)setOn:(BOOL)on
{
    //if( on == _on )
    //    return;
    
    _on = on;
 
    if( !_animationEnabled )
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0];
        
        _layerCheck.strokeEnd = on ? 1.0 : 0.0;
        _layerCheck.strokeStart = 0.0;
        
        [CATransaction commit];
        return;
    }    
    
    if ( on )
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.4];
        
        _layerCheck.strokeEnd = 1.0;
        
        [CATransaction commit];
    }
    else
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.1];
        
        _layerCheck.strokeStart = 0.5;
        _layerCheck.strokeEnd = 0.5;
        
        [CATransaction commit];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.0];
            
            _layerCheck.strokeStart = 0.0;
            _layerCheck.strokeEnd = 0.0;
            
            [CATransaction commit];
        });
    }
    
    CATransform3D mtx = CATransform3DMakeScale(ANIMATION_SCALEFACTOR, ANIMATION_SCALEFACTOR, 1.0);
    _layerBox.transform = mtx;
    _layerCheck.transform = mtx;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
    ^{
        _layerBox.transform = CATransform3DIdentity;
        _layerCheck.transform = CATransform3DIdentity;
    });
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    _animationEnabled = animated;
    self.on = on;
    _animationEnabled = NO;
}

- (void)setColor:(UIColor *)color
{
    _color = color;

    _layerCheck.strokeColor = color.CGColor;
    _layerBox.strokeColor = color.CGColor;
    _layerBox.fillColor = [color colorWithAlphaComponent:CHECKBOX_FILLALPHA].CGColor;
}

- (void)toggleCheckbox
{
    _animationEnabled = YES;
    self.on = !_on;
    _animationEnabled = NO;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if( !_color )
        _color = self.tintColor;
    
    [self createLayers];
    
    _animationEnabled = NO;
    self.on = _on;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    _color = self.tintColor;
    
    [self createLayers];
    
    _animationEnabled = NO;
    self.on = _on;
    return self;
}


@end
