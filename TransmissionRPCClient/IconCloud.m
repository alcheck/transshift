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
    /// bunch of layers
    CAShapeLayer *_layerCloud;
    CAShapeLayer *_layerArrowUp;
    CAShapeLayer *_layerArrowDown;
    CAShapeLayer *_layerCircleArrows;
    CAShapeLayer *_layerStopButton;
    CAShapeLayer *_layerCrossButton;
    CAShapeLayer *_layerLittleArrowUp;
    CAShapeLayer *_layerLittleArrowDown;
    CAShapeLayer *_layerClouds;
    CAShapeLayer *_layerArrows;
    
    /// main layer frame
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
    [self setLayersColors];
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
    CAAnimation *anim = [_layerCircleArrows animationForKey:@"checkAnimation"];
    if( anim )
    {
        CATransform3D mtx = [(CALayer*)(_layerCircleArrows.presentationLayer) transform];
        _layerCircleArrows.transform = mtx;
        [_layerCircleArrows removeAllAnimations];
        
        _layerCircleArrows.transform = CATransform3DIdentity;
    }
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
    return [_layerArrowUp animationForKey:@"uploadAnimation"] != nil;
}

- (void)stopUploadAnimation
{
    CGPoint pOrigin = _layerArrowUp.position;
    CALayer *pLayer = _layerArrowUp.presentationLayer;
    
    _layerArrowUp.position = pLayer.position;
    _layerArrowUp.opacity = pLayer.opacity;
    
    [_layerArrowUp removeAllAnimations];
    
    _layerArrowUp.position = pOrigin;
    _layerArrowUp.opacity = 1.0;
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
    CGPoint pOrigin = _layerArrowDown.position;
    CALayer *pLayer = _layerArrowDown.presentationLayer;
    
    _layerArrowDown.position = pLayer.position;
    _layerArrowDown.opacity = pLayer.opacity;
    
    [_layerArrowDown removeAllAnimations];
    
    _layerArrowDown.position = pOrigin;
    _layerArrowDown.opacity = 1.0;
}

- (BOOL)isDownloadAnimationInProgress
{
    return [_layerArrowDown animationForKey:@"downloadAnimation"] != nil;
}

- (void)playActivityAnimation
{
    if( self.isActivityAnimationInProgress )
        return;
    
    CABasicAnimation *a0 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    a0.beginTime = 0;
    a0.duration = 1.5;
    a0.autoreverses = YES;
    a0.repeatCount = HUGE_VALF;
    a0.byValue = @(-3);
    [_layerLittleArrowUp addAnimation:a0 forKey:@"activityAnimationUp"];
    
    CABasicAnimation *a1 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    a1.beginTime = 0;
    a1.duration = 1.5;
    a1.autoreverses = YES;
    a1.repeatCount = HUGE_VALF;
    a1.byValue = @(3);
    [_layerLittleArrowDown addAnimation:a1 forKey:@"activityAnimationDown"];
    
    [self animateScale];
}

- (void)stopActivityAnimation
{
    CGPoint pOrigin = _layerLittleArrowDown.position;
    CALayer *pLayer = _layerLittleArrowDown.presentationLayer;
    _layerLittleArrowDown.position = pLayer.position;
    [_layerLittleArrowDown removeAllAnimations];
    _layerLittleArrowDown.position = pOrigin;
    
    pOrigin = _layerLittleArrowUp.position;
    pLayer = _layerLittleArrowUp.presentationLayer;
    _layerLittleArrowUp.position = pLayer.position;
    [_layerLittleArrowUp removeAllAnimations];
    _layerLittleArrowUp.position = pOrigin;
}

- (BOOL)isActivityAnimationInProgress
{
    return [_layerLittleArrowUp animationForKey:@"activityAnimationUp"] != nil;
}

- (void)createLayers
{
    _frame = self.frame;
    _frame.origin = CGPointZero;
    
    /////////////////////////////////////
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    /////////////////////////////////////
    
    
    /// CREATE
    _layerCloud = [CAShapeLayer layer];
    
    _layerArrowUp = [CAShapeLayer layer];
    _layerArrowDown = [CAShapeLayer layer];
    
    _layerCircleArrows = [CAShapeLayer layer];
    _layerStopButton = [CAShapeLayer layer];
    _layerCrossButton = [CAShapeLayer layer];
    
    _layerLittleArrowDown = [CAShapeLayer layer];
    _layerLittleArrowUp = [CAShapeLayer layer];
    
    _layerClouds = [CAShapeLayer layer];
    _layerArrows = [CAShapeLayer layer];
    
    /// SCALE
    _layerCrossButton.contentsScale =
    _layerCloud.contentsScale =
    _layerArrowUp.contentsScale =
    _layerArrowDown.contentsScale =
    _layerCircleArrows.contentsScale =
    _layerStopButton.contentsScale =
    _layerLittleArrowDown.contentsScale =
    _layerLittleArrowUp.contentsScale =
    _layerClouds.contentsScale =
    _layerArrows.contentsScale =
    [UIScreen mainScreen].scale;
    
    
    /// LINE WIDTH
    _layerCrossButton.lineWidth =
    _layerArrowUp.lineWidth =
    _layerArrowDown.lineWidth =
    _layerCircleArrows.lineWidth =
    _layerStopButton.lineWidth =
    _layerLittleArrowUp.lineWidth =
    _layerLittleArrowDown.lineWidth =
    _layerArrows.lineWidth =
    1.5;
    
    _layerCloud.lineWidth =
    _layerClouds.lineWidth =
    2.0;
    
    /// LINE CAPS
    _layerCrossButton.lineCap =
    _layerCloud.lineCap =
    _layerArrowDown.lineCap =
    _layerArrowUp.lineCap =
    _layerStopButton.lineCap =
    _layerLittleArrowUp.lineCap =
    _layerLittleArrowDown.lineCap =
    _layerArrows.lineCap =
    _layerClouds.lineCap =
    kCALineCapRound;
    
    _layerCircleArrows.lineCap = kCALineCapSquare;

    /// SET PATHS
    _layerCloud.path = self.cloudPath;
    _layerCircleArrows.path = self.circleArrowsPath;
    _layerArrowDown.path = self.arrowDownPath;
    _layerArrowUp.path = self.arrowUpPath;
    _layerStopButton.path = self.stopButtonPath;
    _layerCrossButton.path = self.crossButtonPath;
    _layerLittleArrowDown.path = self.littleArrowDownPath;
    _layerLittleArrowUp.path = self.littleArrowUpPath;
    _layerArrows.path = self.arrowsPath;
    _layerClouds.path = self.cloudsPath;
    
    /// ADD TO VIEW
    [self.layer addSublayer:_layerCloud];
    [self.layer addSublayer:_layerClouds];
    [self.layer addSublayer:_layerArrows];
    
    [_layerCloud addSublayer:_layerCircleArrows];
    [_layerCloud addSublayer:_layerArrowDown];
    [_layerCloud addSublayer:_layerArrowUp];
    [_layerCloud addSublayer:_layerStopButton];
    [_layerCloud addSublayer:_layerCrossButton];
    
    [_layerCloud addSublayer:_layerLittleArrowDown];
    [_layerCloud addSublayer:_layerLittleArrowUp];

    //////////////////////
    [CATransaction commit];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setLayersColors];
}

- (void)setLayersColors
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    /// STROKE
    _layerCloud.strokeColor =
    _layerArrowUp.strokeColor =
    _layerArrowDown.strokeColor =
    _layerCircleArrows.strokeColor =
    _layerStopButton.strokeColor =
    _layerCrossButton.strokeColor =
    _layerLittleArrowUp.strokeColor =
    _layerLittleArrowDown.strokeColor =
    _layerClouds.strokeColor =
    _layerArrows.strokeColor =
    self.tintColor.CGColor;
    
    /// FILL
    _layerCrossButton.fillColor =
    _layerCloud.fillColor =
    _layerArrowUp.fillColor =
    _layerArrowDown.fillColor =
    _layerCircleArrows.fillColor =
    _layerStopButton.fillColor =
    _layerLittleArrowUp.fillColor =
    _layerLittleArrowDown.fillColor =
    _layerArrows.fillColor =
    _layerClouds.fillColor =
    nil;
    
    [CATransaction commit];
}

- (void)setIconType:(IconCloudType)iconType
{
    if( _iconType == iconType )
        return;
    
    _iconType = iconType;
    
    /// REMOVE ALL ANIMATIONS
    [_layerArrowUp removeAllAnimations];
    [_layerArrowDown removeAllAnimations];
    [_layerCircleArrows removeAllAnimations];
    [_layerLittleArrowDown removeAllAnimations];
    [_layerLittleArrowUp removeAllAnimations];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    
    /// HIDE LAYERS
    _layerCloud.hidden = NO;
    
    _layerCircleArrows.hidden =
    _layerArrowDown.hidden =
    _layerArrowUp.hidden =
    _layerStopButton.hidden =
    _layerCrossButton.hidden =
    _layerLittleArrowUp.hidden =
    _layerLittleArrowDown.hidden =
    _layerClouds.hidden =
    _layerArrows.hidden =
    YES;
    
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
        
        case IconCloudTypeActive:
            _layerLittleArrowDown.hidden = NO;
            _layerLittleArrowUp.hidden = NO;
            break;
        
        case IconCloudTypeAll:
            _layerArrows.hidden = NO;
            _layerClouds.hidden = NO;
            _layerCloud.hidden = YES;
            break;
            
        default:
            break;
    }
    
    [CATransaction commit];
}

- (CGRect)frame2
{
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;
    
    CGRect _frame2 = CGRectMake(floor(w * 0.30488 + 0.5),floor(h * 0.50311 + 0.5), floor(w * 0.71341 + 0.5) - floor(w * 0.30488 + 0.5), floor(h * 0.86335 + 0.5) - floor(h * 0.50311 + 0.5));
    
    return _frame2;
}

- (CGPathRef)cloudPath
{
    //static
    CGPathRef path = NULL;
    
    _layerCloud.frame = _frame;
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

- (CGPathRef)littleArrowUpPath
{
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;
    
    UIBezierPath* arrUpPath = UIBezierPath.bezierPath;
    [arrUpPath moveToPoint: CGPointMake( 0.45200 * w,  0.50074 * h)];
    [arrUpPath addLineToPoint: CGPointMake( 0.45200 * w,  0.78513 * h)];
    [arrUpPath moveToPoint: CGPointMake( 0.35745 * w,  0.59071 * h)];
    [arrUpPath addLineToPoint: CGPointMake( 0.45200 * w,  0.49405 * h)];
    [arrUpPath addLineToPoint: CGPointMake( 0.54655 * w,  0.59071 * h)];
    
    _layerLittleArrowUp.frame = _frame;
    return arrUpPath.CGPath;
}

- (CGPathRef)littleArrowDownPath
{
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;
    
    UIBezierPath* arrDownPath = UIBezierPath.bezierPath;
    [arrDownPath moveToPoint: CGPointMake( 0.61200 * w,  0.87026 * h)];
    [arrDownPath addLineToPoint: CGPointMake( 0.61200 * w,  0.58587 * h)];
    [arrDownPath moveToPoint: CGPointMake( 0.70655 * w,  0.78030 * h)];
    [arrDownPath addLineToPoint: CGPointMake( 0.61200 * w,  0.87695 * h)];
    [arrDownPath addLineToPoint: CGPointMake( 0.51745 * w,  0.78030 * h)];
    
    _layerLittleArrowDown.frame = _frame;
    return arrDownPath.CGPath;
}

- (CGPathRef)cloudsPath
{
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;
    
    UIBezierPath* cloudsPath = UIBezierPath.bezierPath;
    [cloudsPath moveToPoint: CGPointMake(0.44914 * w, 0.74233 * h)];
    [cloudsPath addLineToPoint: CGPointMake(0.33726 * w, 0.74233 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.23247 * w, 0.69888 * h) controlPoint1: CGPointMake(0.29627 * w, 0.74233 * h) controlPoint2: CGPointMake(0.26144 * w, 0.72785 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.18901 * w, 0.59408 * h) controlPoint1: CGPointMake(0.20350 * w, 0.66990 * h) controlPoint2: CGPointMake(0.18901 * w, 0.63507 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.23247 * w, 0.48929 * h) controlPoint1: CGPointMake(0.18901 * w, 0.55309 * h) controlPoint2: CGPointMake(0.20350 * w, 0.51826 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.33726 * w, 0.44583 * h) controlPoint1: CGPointMake(0.26144 * w, 0.46032 * h) controlPoint2: CGPointMake(0.29627 * w, 0.44583 * h)];
    [cloudsPath addLineToPoint: CGPointMake(0.33726 * w, 0.43566 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.39428 * w, 0.29851 * h) controlPoint1: CGPointMake(0.33757 * w, 0.38203 * h) controlPoint2: CGPointMake(0.35668 * w, 0.33642 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.53082 * w, 0.24149 * h) controlPoint1: CGPointMake(0.43219 * w, 0.26059 * h) controlPoint2: CGPointMake(0.47781 * w, 0.24149 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.64918 * w, 0.28032 * h) controlPoint1: CGPointMake(0.57551 * w, 0.24149 * h) controlPoint2: CGPointMake(0.61496 * w, 0.25443 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.71883 * w, 0.38234 * h) controlPoint1: CGPointMake(0.68339 * w, 0.30621 * h) controlPoint2: CGPointMake(0.70681 * w, 0.34042 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.78202 * w, 0.37155 * h) controlPoint1: CGPointMake(0.74041 * w, 0.37525 * h) controlPoint2: CGPointMake(0.76167 * w, 0.37155 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.91208 * w, 0.42580 * h) controlPoint1: CGPointMake(0.83256 * w, 0.37155 * h) controlPoint2: CGPointMake(0.87602 * w, 0.38974 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.96633 * w, 0.55679 * h) controlPoint1: CGPointMake(0.94814 * w, 0.46186 * h) controlPoint2: CGPointMake(0.96633 * w, 0.50562 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.91208 * w, 0.68778 * h) controlPoint1: CGPointMake(0.96633 * w, 0.60795 * h) controlPoint2: CGPointMake(0.94814 * w, 0.65172 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.78202 * w, 0.74202 * h) controlPoint1: CGPointMake(0.87602 * w, 0.72384 * h) controlPoint2: CGPointMake(0.83256 * w, 0.74202 * h)];
    [cloudsPath addLineToPoint: CGPointMake(0.69078 * w, 0.74202 * h)];
    [cloudsPath moveToPoint: CGPointMake(0.45932 * w, 0.22762 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.44082 * w, 0.21128 * h) controlPoint1: CGPointMake(0.45346 * w, 0.22176 * h) controlPoint2: CGPointMake(0.44760 * w, 0.21621 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.33665 * w, 0.17707 * h) controlPoint1: CGPointMake(0.41062 * w, 0.18847 * h) controlPoint2: CGPointMake(0.37579 * w, 0.17707 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.21644 * w, 0.22731 * h) controlPoint1: CGPointMake(0.28980 * w, 0.17707 * h) controlPoint2: CGPointMake(0.24973 * w, 0.19371 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.16620 * w, 0.34905 * h) controlPoint1: CGPointMake(0.18316 * w, 0.26090 * h) controlPoint2: CGPointMake(0.16620 * w, 0.30128 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.16929 * w, 0.35707 * h) controlPoint1: CGPointMake(0.16620 * w, 0.35306 * h) controlPoint2: CGPointMake(0.16744 * w, 0.35552 * h)];
    [cloudsPath addLineToPoint: CGPointMake(0.16620 * w, 0.35707 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.07374 * w, 0.39528 * h) controlPoint1: CGPointMake(0.13014 * w, 0.35707 * h) controlPoint2: CGPointMake(0.09932 * w, 0.36970 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.03552 * w, 0.48775 * h) controlPoint1: CGPointMake(0.04816 * w, 0.42087 * h) controlPoint2: CGPointMake(0.03552 * w, 0.45169 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.07374 * w, 0.58021 * h) controlPoint1: CGPointMake(0.03552 * w, 0.52381 * h) controlPoint2: CGPointMake(0.04816 * w, 0.55463 * h)];
    [cloudsPath addCurveToPoint: CGPointMake(0.16620 * w, 0.61843 * h) controlPoint1: CGPointMake(0.09932 * w, 0.60579 * h) controlPoint2: CGPointMake(0.12984 * w, 0.61843 * h)];
    [cloudsPath addLineToPoint: CGPointMake(0.16929 * w, 0.61843 * h)];
    
    _layerClouds.frame = _frame;
    return cloudsPath.CGPath;
}

- (CGPathRef)arrowsPath
{
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;

    UIBezierPath* arrowsPath = UIBezierPath.bezierPath;
    [arrowsPath moveToPoint: CGPointMake(0.62298 * w, 0.58977 * h)];
    [arrowsPath addLineToPoint: CGPointMake(0.62298 * w, 0.77346 * h)];
    [arrowsPath moveToPoint: CGPointMake(0.56103 * w, 0.64788 * h)];
    [arrowsPath addLineToPoint: CGPointMake(0.62298 * w, 0.58545 * h)];
    [arrowsPath addLineToPoint: CGPointMake(0.68493 * w, 0.64788 * h)];
    [arrowsPath moveToPoint: CGPointMake(0.52065 * w, 0.86469 * h)];
    [arrowsPath addLineToPoint: CGPointMake(0.52065 * w, 0.68100 * h)];
    [arrowsPath moveToPoint: CGPointMake(0.58260 * w, 0.80658 * h)];
    [arrowsPath addLineToPoint: CGPointMake(0.52065 * w, 0.86901 * h)];
    [arrowsPath addLineToPoint: CGPointMake(0.45870 * w, 0.80658 * h)];
    
    _layerArrows.frame = _frame;
    return arrowsPath.CGPath;
}

@end
