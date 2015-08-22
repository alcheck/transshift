//
//  IconHalfCloud.m
//  IconTestApp
//
//  Created by Alexey Chechetkin on 19.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "IconHalfCloud.h"

@implementation IconHalfCloud

{
    CAShapeLayer *_layerCloud;
    CAShapeLayer *_layerArrowUp;
    CAShapeLayer *_layerArrowDown;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
        [self setupValues];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupValues];
}

- (void)setupValues
{
    [self createLayers];
    [self setLayersColors];
    self.iconType = IconHalfCloudTypeNone;
}

- (void)createLayers
{
    _layerCloud = [CAShapeLayer layer];
    _layerArrowUp = [CAShapeLayer layer];
    _layerArrowDown = [CAShapeLayer layer];
    
    _layerCloud.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _layerCloud.lineWidth = 1.5;
    
    _layerArrowDown.lineWidth = _layerArrowUp.lineWidth = _layerCloud.lineWidth + 0.5;
    
    _layerCloud.lineCap = _layerArrowUp.lineCap = _layerArrowDown.lineCap = kCALineCapRound;
    
    _layerCloud.path = self.cloudPath;
    _layerArrowDown.path = self.arrowDownPath;
    _layerArrowUp.path = self.arrowUpPath;
    
    [_layerCloud addSublayer:_layerArrowUp];
    [_layerCloud addSublayer:_layerArrowDown];
    
    [self.layer addSublayer:_layerCloud];
}

- (void)setIconType:(IconHalfCloudType)iconType
{
    _iconType = iconType;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];

    _layerArrowDown.hidden = YES;
    _layerArrowUp.hidden = YES;
    
    switch (iconType)
    {
        case IconHalfCloudTypeDownload:
            _layerArrowDown.hidden = NO;
            break;
            
        case IconHalfCloudTypeUpload:
            _layerArrowUp.hidden = NO;
            break;
            
        default:
            break;
    }
    
    [CATransaction commit];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setLayersColors];
}

- (void)setLayersColors
{
    _layerCloud.fillColor = [UIColor clearColor].CGColor;
    _layerArrowDown.fillColor = [UIColor clearColor].CGColor;
    _layerArrowUp.fillColor = [UIColor clearColor].CGColor;
    
    _layerCloud.strokeColor = self.tintColor.CGColor;
    _layerArrowDown.strokeColor = self.tintColor.CGColor;
    _layerArrowUp.strokeColor = self.tintColor.CGColor;
}

- (void)animateScale
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3];
    [CATransaction setCompletionBlock:^{ _layerCloud.transform = CATransform3DIdentity; }];
    _layerCloud.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
    [CATransaction commit];
}

- (CAAnimation *)animationPositionByValue:(CGFloat)val
{
    CAAnimationGroup *grp = [CAAnimationGroup animation];
    grp.duration = 2.0;
    grp.repeatCount = HUGE_VALF;
    
    CABasicAnimation *a0 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    a0.beginTime = 0;
    a0.duration = 1.5;
    a0.byValue = @(val);
    
    CABasicAnimation *a1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    a1.beginTime = .5;
    a1.duration = 1.0;
    a1.fromValue = @(1.0);
    a1.toValue = @(0.0);
    
    CABasicAnimation *a2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    a2.beginTime = 1.5;
    a2.duration = 0.5;
    a2.fromValue = @(0);
    a2.toValue = @(1);
    
    grp.animations = @[ a0, a1, a2 ];
    return grp;
}

- (void)playDownloadAnimation
{
    if( self.isDownloadAnimationInProgress )
        return;

    [_layerArrowDown addAnimation:[self animationPositionByValue:4]  forKey:@"downloadAnimation"];
    
    [self animateScale];
}

- (void)playUploadAnimation
{
    if( self.isUploadAnimationInProgress )
        return;
 
    [_layerArrowUp addAnimation:[self animationPositionByValue:-4] forKey:@"uploadAnimation"];
    
    [self animateScale];
}

- (BOOL)isDownloadAnimationInProgress
{
    return [_layerArrowDown animationForKey:@"downloadAnimation"] != nil;
}

- (BOOL)isUploadAnimationInProgress
{
    return [_layerArrowUp animationForKey:@"uploadAnimation"] != nil;
}

- (void)stopDownloadAnimation
{
    CGPoint pOrigin = _layerArrowDown.position;
    CALayer *pLayer = _layerArrowDown.presentationLayer;
    _layerArrowDown.position = pLayer.position;
    _layerArrowDown.opacity = pLayer.opacity;
    [_layerArrowDown removeAllAnimations];
    
    _layerArrowDown.opacity = 1.0f;
    _layerArrowDown.position = pOrigin;
}

- (void)stopUploadAnimation
{
    CGPoint pOrigin = _layerArrowUp.position;
    CALayer *pLayer = _layerArrowUp.presentationLayer;
    _layerArrowUp.position = pLayer.position;
    _layerArrowUp.opacity = pLayer.opacity;
    [_layerArrowUp removeAllAnimations];
    
    _layerArrowUp.opacity = 1.0f;
    _layerArrowUp.position = pOrigin;
}

- (CGPathRef)cloudPath
{
    //static
    CGPathRef path = NULL;
    
    if( path == NULL )
    {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        UIBezierPath* cloudPath = UIBezierPath.bezierPath;
        [cloudPath moveToPoint: CGPointMake(0.87551 * w, 0.06000 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.67878 * w, 0.00694 * h) controlPoint1: CGPointMake(0.81673 * w, 0.02531 * h) controlPoint2: CGPointMake(0.75143 * w, 0.00694 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.40939 * w, 0.11918 * h) controlPoint1: CGPointMake(0.57429 * w, 0.00694 * h) controlPoint2: CGPointMake(0.48449 * w, 0.04449 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.29714 * w, 0.39184 * h) controlPoint1: CGPointMake(0.33429 * w, 0.19388 * h) controlPoint2: CGPointMake(0.29714 * w, 0.28490 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.30367 * w, 0.40980 * h) controlPoint1: CGPointMake(0.29714 * w, 0.40082 * h) controlPoint2: CGPointMake(0.30000 * w, 0.40612 * h)];
        [cloudPath addLineToPoint: CGPointMake(0.29714 * w, 0.40980 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.09020 * w, 0.49551 * h) controlPoint1: CGPointMake(0.21633 * w, 0.40980 * h) controlPoint2: CGPointMake(0.14735 * w, 0.43837 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.00449 * w, 0.70245 * h) controlPoint1: CGPointMake(0.03306 * w, 0.55265 * h) controlPoint2: CGPointMake(0.00449 * w, 0.62163 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.09020 * w, 0.90939 * h) controlPoint1: CGPointMake(0.00449 * w, 0.78327 * h) controlPoint2: CGPointMake(0.03306 * w, 0.85224 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.29714 * w, 0.99510 * h) controlPoint1: CGPointMake(0.14735 * w, 0.96653 * h) controlPoint2: CGPointMake(0.21633 * w, 0.99510 * h)];
        [cloudPath addLineToPoint: CGPointMake(0.87551 * w, 0.99510 * h)];
        
        path = cloudPath.CGPath;
    }
    return path;
}

- (CGRect)frame2
{
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    return  CGRectMake(floor(w * 0.9 + 0.5), floor(h * 0.18776 + 0.5),
                       floor(w * 1.11837 + 0.5) - floor(w * 0.76327 + 0.5),
                       floor(h * 0.92245 + 0.5) - floor(h * 0.18776 + 0.5));

}

- (CGPathRef)arrowUpPath
{
    //static
    CGPathRef path = NULL;

    CGRect frame2 = self.frame2;
    _layerArrowUp.frame = frame2;
    
    if( path == NULL )
    {
        CGFloat w = frame2.size.width;
        CGFloat h = frame2.size.height;
        
        UIBezierPath* arrowUpPath = UIBezierPath.bezierPath;
        [arrowUpPath moveToPoint: CGPointMake(0.49877 * w, 0.00611 * h)];
        [arrowUpPath addLineToPoint: CGPointMake(0.49893 * w, 0.98167 * h)];
        [arrowUpPath moveToPoint: CGPointMake(0.01720 * w, 0.23002 * h)];
        [arrowUpPath addLineToPoint: CGPointMake(0.49877 * w, 0.00611 * h)];
        [arrowUpPath moveToPoint: CGPointMake(0.98042 * w, 0.22998 * h)];
        [arrowUpPath addLineToPoint: CGPointMake(0.49877 * w, 0.00611 * h)];
        path = arrowUpPath.CGPath;
    }
    return path;
}

- (CGPathRef)arrowDownPath
{
    //static
    CGPathRef path = NULL;
    
    CGRect frame2 = self.frame2;
    _layerArrowDown.frame = frame2;
    
    if( path == NULL )
    {
        CGFloat w = frame2.size.width;
        CGFloat h = frame2.size.height;
        
        UIBezierPath* arrowDownPath = UIBezierPath.bezierPath;
        [arrowDownPath moveToPoint: CGPointMake(0.49884 * w, 0.98167 * h)];
        [arrowDownPath addLineToPoint: CGPointMake(0.49868 * w, 0.00611 * h)];
        [arrowDownPath moveToPoint: CGPointMake(0.98042 * w, 0.75776 * h)];
        [arrowDownPath addLineToPoint: CGPointMake(0.49884 * w, 0.98167 * h)];
        [arrowDownPath moveToPoint: CGPointMake(0.01720 * w, 0.75780 * h)];
        [arrowDownPath addLineToPoint: CGPointMake(0.49884 * w, 0.98167 * h)];
        
        path = arrowDownPath.CGPath;
    }
    return path;
}

@end
