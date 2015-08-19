//
//  IconCloud.m
//  IconTestApp
//
//  Created by Alexey Chechetkin on 18.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "IconCloud.h"

@implementation IconCloud

{
    CAShapeLayer *_layerCloud;
    CAShapeLayer *_layerArrowUp;
    CAShapeLayer *_layerArrowDown;
    CAShapeLayer *_layerCircleArrows;
    CAShapeLayer *_layerStopButton;
    CAShapeLayer *_layerCrossButton;
    
    CGRect      _frame;
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
    [self setLayersStrokeColor];
    self.iconType = IconCloudTypeNone;
}

- (void)animateScale
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3];
    [CATransaction setCompletionBlock:^{ _layerCloud.transform = CATransform3DIdentity; }];
    _layerCloud.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
    [CATransaction commit];
}

- (void)playCheckAnimation
{
    if( self.isCheckAnimationInProgress )
        return;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.duration = 2.0;
    anim.fromValue = @0.0;
    anim.toValue = @(-2 * M_PI);
    anim.repeatCount = HUGE_VALF;
    [_layerCircleArrows addAnimation:anim forKey:@"checkAnimation"];
    
    [self animateScale];
 }

- (void)stopCheckAnimation
{
    [_layerCircleArrows removeAllAnimations];
}

- (BOOL)isCheckAnimationInProgress
{
    return [_layerCircleArrows animationForKey:@"checkAnimation"] != nil;
}

- (void)playUploadAnimation
{
    if( self.isUploadAnimationInProgress )
        return;
    
    CAAnimationGroup *grp = [CAAnimationGroup animation];
    grp.duration = 2.0;
    grp.repeatCount = HUGE_VALF;
    
    CABasicAnimation *a0 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    a0.beginTime = 0;
    a0.duration = 1.5;
    a0.byValue = @(-7);
    
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
    [_layerArrowUp addAnimation:grp forKey:@"uploadAnimation"];
    
    [self animateScale];
}

- (BOOL)isUploadAnimationInProgress
{
    return [_layerArrowUp animationForKey:@"uploadAnimation"];
}

- (void)stopUploadAnimation
{
    [_layerArrowUp removeAllAnimations];
}

- (void)playDownloadAnimation
{
    if( self.isDownloadAnimationInProgress )
        return;
    
    CAAnimationGroup *grp = [CAAnimationGroup animation];
    grp.duration = 2.0;
    grp.repeatCount = HUGE_VALF;
    
    CABasicAnimation *a0 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    a0.beginTime = 0;
    a0.duration = 1.5;
    a0.byValue = @(7);
    
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
    [_layerArrowDown addAnimation:grp forKey:@"downloadAnimation"];
    
    [self animateScale];
}

- (void)stopDownloadAnimation
{
    [_layerArrowDown removeAllAnimations];
}

- (BOOL)isDownloadAnimationInProgress
{
    return [_layerArrowDown animationForKey:@"downloadAnimation"];
}

- (void)createLayers
{
    _layerCloud = [CAShapeLayer layer];
    _layerArrowUp = [CAShapeLayer layer];
    _layerArrowDown = [CAShapeLayer layer];
    _layerCircleArrows = [CAShapeLayer layer];
    _layerStopButton = [CAShapeLayer layer];
    _layerCrossButton = [CAShapeLayer layer];
    
    _layerCrossButton.contentsScale = _layerCloud.contentsScale = _layerArrowUp.contentsScale = _layerArrowDown.contentsScale = _layerCircleArrows.contentsScale = _layerStopButton.contentsScale = [UIScreen mainScreen].scale;
    
    _frame = self.frame;
    _frame.origin = CGPointZero;
    
    _layerCloud.frame = _frame;
    
    _layerCrossButton.fillColor = _layerCloud.fillColor = _layerArrowUp.fillColor = _layerArrowDown.fillColor = _layerCircleArrows.fillColor = _layerStopButton.fillColor = [UIColor clearColor].CGColor;
    
     _layerCrossButton.lineWidth = _layerArrowUp.lineWidth = _layerArrowDown.lineWidth = _layerCircleArrows.lineWidth = _layerStopButton.lineWidth = 1.5;
    
    _layerCloud.lineWidth = 2.0;
    
    _layerCrossButton.lineCap = _layerCloud.lineCap = _layerArrowDown.lineCap = _layerArrowUp.lineCap =  _layerStopButton.lineCap = kCALineCapRound;
    
    _layerCloud.path = self.cloudPath;
    
    _layerCircleArrows.path = self.circleArrowsPath;
    _layerCircleArrows.lineCap = kCALineCapSquare;
    
    _layerArrowDown.path = self.arrowDownPath;
    _layerArrowUp.path = self.arrowUpPath;
    _layerStopButton.path = self.stopButtonPath;
    _layerCrossButton.path = self.crossButtonPath;
    
    [self.layer addSublayer:_layerCloud];
    
    [_layerCloud addSublayer:_layerCircleArrows];
    [_layerCloud addSublayer:_layerArrowDown];
    [_layerCloud addSublayer:_layerArrowUp];
    [_layerCloud addSublayer:_layerStopButton];
    [_layerCloud addSublayer:_layerCrossButton];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setLayersStrokeColor];
}

- (void)setLayersStrokeColor
{
    _layerCloud.strokeColor = _layerArrowUp.strokeColor = _layerArrowDown.strokeColor = _layerCircleArrows.strokeColor = _layerStopButton.strokeColor = _layerCrossButton.strokeColor = self.tintColor.CGColor;
}

- (void)setIconType:(IconCloudType)iconType
{
    if( _iconType == iconType )
        return;
    
    _iconType = iconType;
    
    [_layerArrowUp removeAllAnimations];
    [_layerArrowDown removeAllAnimations];
    [_layerCircleArrows removeAllAnimations];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.0];
    
    _layerCircleArrows.hidden = YES;
    _layerArrowDown.hidden = YES;
    _layerArrowUp.hidden = YES;
    _layerStopButton.hidden = YES;
    _layerCrossButton.hidden = YES;
    
    switch (iconType)
    {
        case IconCloudTypeDownload:
            _layerArrowDown.hidden = NO;
            break;
            
        case IconCloudTypeUpload:
            _layerArrowUp.hidden = NO;
            break;
            
        case IconCloudTypeCheck:
            _layerCircleArrows.hidden = NO;
            break;
            
        case IconCloudTypeStop:
            _layerStopButton.hidden = NO;
            break;
            
        case IconCloudTypeError:
            _layerCrossButton.hidden = NO;
            break;
            
        default:
            break;
    }
    
    [CATransaction commit];
}

- (CGPathRef)cloudPath
{
    //static
    CGPathRef path = NULL;
    
    if( path == NULL )
    {
        CGFloat w = _frame.size.width;
        CGFloat h = _frame.size.height;
        
        UIBezierPath* cloudPath = UIBezierPath.bezierPath;
        [cloudPath moveToPoint: CGPointMake(0.24846 * w, 0.71086 * h)];
        [cloudPath addLineToPoint: CGPointMake(0.20217 * w, 0.71086 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.07020 * w, 0.65506 * h) controlPoint1: CGPointMake(0.15077 * w, 0.71086 * h) controlPoint2: CGPointMake(0.10666 * w, 0.69226 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.01917 * w, 0.52041 * h) controlPoint1: CGPointMake(0.03375 * w, 0.61787 * h) controlPoint2: CGPointMake(0.01917 * w, 0.57286 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.04760 * w, 0.41179 * h) controlPoint1: CGPointMake(0.01917 * w, 0.47949 * h) controlPoint2: CGPointMake(0.02609 * w, 0.44303 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.13801 * w, 0.34148 * h) controlPoint1: CGPointMake(0.06911 * w, 0.38054 * h) controlPoint2: CGPointMake(0.09900 * w, 0.35710 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.18139 * w, 0.24997 * h) controlPoint1: CGPointMake(0.14165 * w, 0.30577 * h) controlPoint2: CGPointMake(0.15623 * w, 0.27527 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.27362 * w, 0.21240 * h) controlPoint1: CGPointMake(0.20654 * w, 0.22505 * h) controlPoint2: CGPointMake(0.23716 * w, 0.21240 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.34726 * w, 0.23547 * h) controlPoint1: CGPointMake(0.29731 * w, 0.21240 * h) controlPoint2: CGPointMake(0.32210 * w, 0.22021 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.44167 * w, 0.13057 * h) controlPoint1: CGPointMake(0.36986 * w, 0.19194 * h) controlPoint2: CGPointMake(0.40121 * w, 0.15698 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.57546 * w, 0.09114 * h) controlPoint1: CGPointMake(0.48177 * w, 0.10416 * h) controlPoint2: CGPointMake(0.52661 * w, 0.09114 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.75555 * w, 0.16628 * h) controlPoint1: CGPointMake(0.64582 * w, 0.09114 * h) controlPoint2: CGPointMake(0.70597 * w, 0.11606 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.82991 * w, 0.34892 * h) controlPoint1: CGPointMake(0.80512 * w, 0.21612 * h) controlPoint2: CGPointMake(0.82991 * w, 0.27713 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.82809 * w, 0.36045 * h) controlPoint1: CGPointMake(0.82991 * w, 0.35264 * h) controlPoint2: CGPointMake(0.82918 * w, 0.35673 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.93454 * w, 0.41737 * h) controlPoint1: CGPointMake(0.86819 * w, 0.36566 * h) controlPoint2: CGPointMake(0.90392 * w, 0.38463 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.98083 * w, 0.53380 * h) controlPoint1: CGPointMake(0.96516 * w, 0.45010 * h) controlPoint2: CGPointMake(0.98083 * w, 0.48879 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.93089 * w, 0.65878 * h) controlPoint1: CGPointMake(0.98083 * w, 0.58253 * h) controlPoint2: CGPointMake(0.96406 * w, 0.62419 * h)];
        [cloudPath addCurveToPoint: CGPointMake(0.80913 * w, 0.71086 * h) controlPoint1: CGPointMake(0.89772 * w, 0.69338 * h) controlPoint2: CGPointMake(0.85689 * w, 0.71086 * h)];
        [cloudPath addLineToPoint: CGPointMake(0.76976 * w, 0.71086 * h)];
        
        path = cloudPath.CGPath;
    }
    
    return path;
}

- (CGRect)frame2
{
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;
    
    CGRect _frame2 = CGRectMake(floor(w * 0.30488 + 0.5),floor(h * 0.50311 + 0.5), floor(w * 0.71341 + 0.5) - floor(w * 0.30488 + 0.5), floor(h * 0.86335 + 0.5) - floor(h * 0.50311 + 0.5));
    
    return _frame2;
}

- (CGPathRef)circleArrowsPath
{
    //static
    CGPathRef path = NULL;
    
    CGRect frame2 = self.frame2;
    _layerCircleArrows.frame = frame2;
    
    if ( path == NULL )
    {
        CGFloat w2 = frame2.size.width;
        CGFloat h2 = frame2.size.height;
        
        UIBezierPath* circleArrowsPath = UIBezierPath.bezierPath;
        [circleArrowsPath moveToPoint: CGPointMake(0.08687 * w2, 0.42079 * h2)];
        [circleArrowsPath addCurveToPoint: CGPointMake(0.49224 * w2, 0.02726 * h2) controlPoint1: CGPointMake(0.12259 * w2, 0.19681 * h2) controlPoint2: CGPointMake(0.29045 * w2, 0.02726 * h2)];
        [circleArrowsPath addCurveToPoint: CGPointMake(0.89760 * w2, 0.42079 * h2) controlPoint1: CGPointMake(0.69403 * w2, 0.02726 * h2) controlPoint2: CGPointMake(0.86188 * w2, 0.19681 * h2)];
        [circleArrowsPath moveToPoint: CGPointMake(0.30116 * w2, 0.36008 * h2)];
        [circleArrowsPath addLineToPoint: CGPointMake(0.08152 * w2, 0.41974 * h2)];
        [circleArrowsPath addLineToPoint: CGPointMake(0.03062 * w2, 0.16228 * h2)];
        [circleArrowsPath moveToPoint: CGPointMake(0.89760 * w2, 0.56940 * h2)];
        [circleArrowsPath addCurveToPoint: CGPointMake(0.49224 * w2, 0.96292 * h2) controlPoint1: CGPointMake(0.86188 * w2, 0.79338 * h2) controlPoint2: CGPointMake(0.69403 * w2, 0.96292 * h2)];
        [circleArrowsPath addCurveToPoint: CGPointMake(0.08687 * w2, 0.56940 * h2) controlPoint1: CGPointMake(0.29045 * w2, 0.96292 * h2) controlPoint2: CGPointMake(0.12259 * w2, 0.79338 * h2)];
        [circleArrowsPath moveToPoint: CGPointMake(0.68688 * w2, 0.66464 * h2)];
        [circleArrowsPath addLineToPoint: CGPointMake(0.89760 * w2, 0.56940 * h2)];
        [circleArrowsPath addLineToPoint: CGPointMake(0.97885 * w2, 0.81640 * h2)];
        path = circleArrowsPath.CGPath;
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
        [arrowDownPath moveToPoint: CGPointMake( 0.49491 * w, 0.90623 * h)];
        [arrowDownPath addLineToPoint: CGPointMake( 0.49491 * w, 0.09178 * h)];
        [arrowDownPath moveToPoint: CGPointMake( 0.73398 * w, 0.64858 * h)];
        [arrowDownPath addLineToPoint: CGPointMake( 0.49491 * w, 0.92539 * h)];
        [arrowDownPath addLineToPoint: CGPointMake( 0.25583 * w, 0.64858 * h)];
        path = arrowDownPath.CGPath;
    }
    return path;
}

-(CGPathRef)arrowUpPath
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
        [arrowUpPath moveToPoint: CGPointMake(0.49491 * w,  0.11094 * h)];
        [arrowUpPath addLineToPoint:CGPointMake( 0.49491 * w,  0.92539 * h)];
        [arrowUpPath moveToPoint:CGPointMake( 0.25583 * w,  0.36858 * h)];
        [arrowUpPath addLineToPoint: CGPointMake(0.49491 * w,  0.09178 * h)];
        [arrowUpPath addLineToPoint: CGPointMake(0.73398 * w,  0.36858 * h)];
        path = arrowUpPath.CGPath;
    }
    return path;
}

- (CGPathRef)stopButtonPath
{
    //static
    CGPathRef path = NULL;
    
    CGRect frame2 = self.frame2;
    _layerStopButton.frame = frame2;
    
    if( path == NULL )
    {
        CGFloat w = frame2.size.width;
        CGFloat h = frame2.size.height;
        
        UIBezierPath* btnPath = UIBezierPath.bezierPath;
        [btnPath moveToPoint: CGPointMake(0.90299 * w,  0.50431 * h)];
        [btnPath addCurveToPoint: CGPointMake(0.49627 * w,  0.03448 * h) controlPoint1: CGPointMake(0.90299 * w,  0.24483 * h) controlPoint2: CGPointMake(0.72089 * w,  0.03448 * h)];
        [btnPath addCurveToPoint: CGPointMake(0.08955 * w,  0.50431 * h) controlPoint1: CGPointMake(0.27165 * w,  0.03448 * h) controlPoint2: CGPointMake(0.08955 * w,  0.24483 * h)];
        [btnPath addCurveToPoint: CGPointMake(0.49627 * w,  0.97414 * h) controlPoint1: CGPointMake(0.08955 * w,  0.76379 * h) controlPoint2: CGPointMake(0.27165 * w,  0.97414 * h)];
        [btnPath addCurveToPoint: CGPointMake(0.90299 * w,  0.50431 * h) controlPoint1: CGPointMake(0.72089 * w,  0.97414 * h) controlPoint2: CGPointMake(0.90299 * w,  0.76379 * h)];
        [btnPath closePath];
        [btnPath moveToPoint: CGPointMake(0.40299 * w,  0.37069 * h)];
        [btnPath addLineToPoint: CGPointMake(0.40299 * w,  0.66379 * h)];
        [btnPath moveToPoint: CGPointMake(0.56716 * w,  0.37069 * h)];
        [btnPath addLineToPoint: CGPointMake(0.56716 * w,  0.66379 * h)];
        path = btnPath.CGPath;
    }
    
    return path;
}

- (CGPathRef)crossButtonPath
{
    //static
    CGPathRef path = NULL;
    
    CGRect frame2 = self.frame2;
    _layerCrossButton.frame = frame2;
    
    if( path == NULL )
    {
        CGFloat w = frame2.size.width;
        CGFloat h = frame2.size.height;
        
        UIBezierPath* errPath = UIBezierPath.bezierPath;
        [errPath moveToPoint: CGPointMake(0.79468 * w, 0.82354 * h)];
        [errPath addCurveToPoint: CGPointMake(0.90299 * w, 0.50431 * h) controlPoint1: CGPointMake(0.86190 * w, 0.73973 * h) controlPoint2: CGPointMake(0.90299 * w, 0.62757 * h)];
        [errPath addCurveToPoint: CGPointMake(0.49627 * w, 0.03448 * h) controlPoint1: CGPointMake(0.90299 * w, 0.24483 * h) controlPoint2: CGPointMake(0.72089 * w, 0.03448 * h)];
        [errPath addCurveToPoint: CGPointMake(0.08955 * w, 0.50431 * h) controlPoint1: CGPointMake(0.27165 * w, 0.03448 * h) controlPoint2: CGPointMake(0.08955 * w, 0.24483 * h)];
        [errPath addCurveToPoint: CGPointMake(0.49627 * w, 0.97414 * h) controlPoint1: CGPointMake(0.08955 * w, 0.76379 * h) controlPoint2: CGPointMake(0.27165 * w, 0.97414 * h)];
        [errPath addCurveToPoint: CGPointMake(0.79468 * w, 0.82354 * h) controlPoint1: CGPointMake(0.61419 * w, 0.97414 * h) controlPoint2: CGPointMake(0.72040 * w, 0.91616 * h)];
        [errPath closePath];
        [errPath moveToPoint: CGPointMake(0.34018 * w, 0.32990 * h)];
        [errPath addLineToPoint: CGPointMake(0.64624 * w, 0.68345 * h)];
        [errPath moveToPoint: CGPointMake(0.35075 * w, 0.68345 * h)];
        [errPath addLineToPoint: CGPointMake(0.65681 * w, 0.32990 * h)];
        
        path = errPath.CGPath;
    }
    
    return path;
}

@end
