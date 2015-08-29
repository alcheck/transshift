//
//  iconFS.m
//  IconTestApp
//
//  Created by Alexey Chechetkin on 18.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "IconFS.h"

@implementation IconFS

{
    CAShapeLayer *_layerOut;
    CAShapeLayer *_layerIn;
    CAShapeLayer *_layerOval;
    CAShapeLayer *_layerCheck;
    
    CAShapeLayer *_layerFolderOut;
    CAShapeLayer *_layerFolderCheck;
    
    CGRect _frame;
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
    [self setStrokeColors];
    
    self.iconType = IconFSTypeNone;
}

- (void)createLayers
{
    //NSLog( @"%p - %s", self, __PRETTY_FUNCTION__ );
    
    _frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    _layerOut = [CAShapeLayer layer];
    _layerIn = [CAShapeLayer layer];
    _layerOval = [CAShapeLayer layer];
    _layerCheck = [CAShapeLayer layer];
    
    _layerFolderOut = [CAShapeLayer layer];
    _layerFolderCheck = [CAShapeLayer layer];
    
    _layerFolderCheck.contentsScale = _layerFolderOut.contentsScale = _layerOut.contentsScale = _layerIn.contentsScale = _layerOval.contentsScale = _layerCheck.contentsScale = [UIScreen mainScreen].scale;
    
    _layerOut.frame = _layerIn.frame = _frame;
  
    _layerOut.lineWidth = 1.5;
    _layerIn.lineWidth = 2.0;
    
    _layerOval.lineWidth = 1.5;
    _layerCheck.lineWidth = 2.0;
    
    _layerFolderOut.lineWidth = 1.5;
    _layerFolderCheck.lineWidth = 1.5;
    
    _layerOut.lineJoin = kCALineJoinRound;
    _layerOut.path = [self outPath];
    
    _layerIn.lineCap = kCALineCapButt;
    _layerIn.path = [self inPath];
    
    _layerOval.path = [self ovalPath];
    
    _layerCheck.lineCap = kCALineCapSquare;
    _layerCheck.path = [self checkPath];
    _layerCheck.strokeEnd = 0;
    
    _layerFolderOut.path = [self folderOutPath];
    _layerFolderCheck.path = [self folderCheckPath];
    
    [self.layer addSublayer:_layerFolderOut];
    
    [self.layer addSublayer:_layerOut];
    [self.layer addSublayer:_layerIn];
    
    [_layerIn addSublayer:_layerOval];
    [_layerIn addSublayer:_layerCheck];
    
    [_layerFolderOut addSublayer:_layerFolderCheck];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setStrokeColors];
}

- (void)setStrokeColors
{
    _layerOut.fillColor = [UIColor clearColor].CGColor;
    _layerOut.strokeColor = self.tintColor.CGColor;
    _layerIn.strokeColor = self.tintColor.CGColor;
    _layerOval.fillColor = [UIColor whiteColor].CGColor;
    _layerOval.strokeColor = self.tintColor.CGColor;
    _layerCheck.fillColor = [UIColor clearColor].CGColor;
    _layerCheck.strokeColor = self.tintColor.CGColor;
    _layerFolderCheck.strokeColor = self.tintColor.CGColor;
    _layerFolderCheck.fillColor = [UIColor clearColor].CGColor;
    _layerFolderOut.fillColor = [UIColor clearColor].CGColor;
    _layerFolderOut.strokeColor = self.tintColor.CGColor;
}

- (void)setIconType:(IconFSType)iconType
{
    if( _iconType == iconType )
        return;
    
    _iconType = iconType;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
    _layerIn.hidden = YES;
    _layerOut.hidden = YES;
    _layerOval.hidden = YES;
    _layerCheck.hidden = YES;
    _layerFolderOut.hidden = YES;
    _layerFolderCheck.hidden = YES;
    
    _layerIn.strokeEnd = 1.0;
    
    _layerIn.transform = _layerOut.transform = _layerOval.transform = _layerCheck.transform = _layerFolderCheck.transform = _layerFolderOut.transform = CATransform3DIdentity;
    
    switch (iconType)
    {
        case IconFSTypeFile:
            _layerIn.hidden = NO;
            _layerOut.hidden = NO;
            
            _layerCheck.strokeEnd = 0;
            _layerCheck.strokeStart = 0;
            break;
            
        case IconFSTypeFileFinished:
            _layerIn.hidden = NO;
            _layerOut.hidden = NO;
            _layerOval.hidden = NO;
            _layerCheck.hidden = NO;
            
            _layerCheck.strokeEnd = 1.0;
            break;
            
        case IconFSTypeFolderClosed:
            _layerFolderOut.hidden = NO;
            _layerFolderCheck.hidden = NO;
            break;
            
       case IconFSTypeFolderOpened:
            _layerFolderOut.hidden = NO;
            _layerFolderCheck.hidden = NO;
            
            _layerFolderCheck.transform = CATransform3DMakeRotation(90 * M_PI/180.0, 0, 0, 1);
            break;
            
        default:
            break;
    }
    
    [CATransaction commit];
}

- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    _downloadProgress = downloadProgress;
    _layerIn.strokeEnd = downloadProgress;
}

- (CGPathRef)outPath
{
    //static
    CGPathRef path = NULL;
    
    if( path == NULL )
    {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        UIBezierPath* outsidePath = UIBezierPath.bezierPath;
        [outsidePath moveToPoint: CGPointMake(0.09215 * w, 0.99074 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.09215 * w, 0.01049 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.58786 * w, 0.01049 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.91049 * w, 0.18483 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.91049 * w, 0.99074 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.09215 * w, 0.99074 * h)];
        [outsidePath closePath];
        [outsidePath moveToPoint: CGPointMake(0.58786 * w, 0.01049 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.65623 * w, 0.25720 * h)];
        [outsidePath addLineToPoint: CGPointMake(0.91049 * w, 0.18483 * h)];
        path = outsidePath.CGPath;
    }
    
    return path;
}

- (CGPathRef)inPath
{
    //static
    CGPathRef path = NULL;
    
    if( path == NULL )
    {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        UIBezierPath* insidePath = UIBezierPath.bezierPath;
        [insidePath moveToPoint: CGPointMake(0.28306 * w, 0.46158 * h)];
        [insidePath addLineToPoint: CGPointMake(0.44856 * w, 0.46158 * h)];
        [insidePath moveToPoint: CGPointMake(0.28306 * w, 0.55698 * h)];
        [insidePath addLineToPoint: CGPointMake(0.44856 * w, 0.55698 * h)];
        [insidePath moveToPoint: CGPointMake(0.28306 * w, 0.64908 * h)];
        [insidePath addLineToPoint: CGPointMake(0.44856 * w, 0.64908 * h)];
        [insidePath moveToPoint: CGPointMake(0.28306 * w, 0.74447 * h)];
        [insidePath addLineToPoint: CGPointMake(0.44856 * w, 0.74447 * h)];
        [insidePath moveToPoint: CGPointMake(0.28306 * w, 0.83658 * h)];
        [insidePath addLineToPoint: CGPointMake(0.44856 * w, 0.83658 * h)];
        [insidePath moveToPoint: CGPointMake(0.52469 * w, 0.46158 * h)];
        [insidePath addLineToPoint: CGPointMake(0.69018 * w, 0.46158 * h)];
        [insidePath moveToPoint: CGPointMake(0.52469 * w, 0.55698 * h)];
        [insidePath addLineToPoint: CGPointMake(0.69018 * w, 0.55698 * h)];
        [insidePath moveToPoint: CGPointMake(0.52469 * w, 0.64908 * h)];
        [insidePath addLineToPoint: CGPointMake(0.69018 * w, 0.64908 * h)];
        [insidePath moveToPoint: CGPointMake(0.52469 * w, 0.74447 * h)];
        [insidePath addLineToPoint: CGPointMake(0.69018 * w, 0.74447 * h)];
        [insidePath moveToPoint: CGPointMake(0.52469 * w, 0.83658 * h)];
        [insidePath addLineToPoint: CGPointMake(0.69018 * w, 0.83658 * h)];
        path = insidePath.CGPath;
    }
    
    return path;
}

- (CGPathRef)ovalPath
{
    //static
    CGPathRef path = NULL;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    CGRect frame2 = CGRectMake(floor(w * 0.62727 + 0.5), floor(h * 0.36364 + 0.5), floor(w * 1.00000 + 0.5) - floor(w * 0.52727 + 0.5), floor(h * 0.83636 + 0.5) - floor(h * 0.36364 + 0.5));
    
    _layerOval.frame = frame2;
    
    if( path == NULL )
    {
        w = frame2.size.width;
        h = frame2.size.height;
        
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(floor(w * 0.05769) + 0.5, floor(h * 0.05769 + 0.5), floor(w * 0.96154 + 0.5) - floor(w * 0.05769) - 0.5, floor(h * 0.96154) - floor(h * 0.05769 + 0.5) + 0.5)];

        path = ovalPath.CGPath;
    }
    
    return path;
}

- (CGPathRef)checkPath
{
    //static
    CGPathRef path = NULL;

    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    CGRect frame2 = CGRectMake(floor(w * 0.62727 + 0.5), floor(h * 0.36364 + 0.5), floor(w * 1.00000 + 0.5) - floor(w * 0.52727 + 0.5), floor(h * 0.83636 + 0.5) - floor(h * 0.36364 + 0.5));
    
    _layerCheck.frame = frame2;
    
    if( path == NULL )
    {
        w = frame2.size.width;
        h = frame2.size.height;
        
        UIBezierPath* checkPath = UIBezierPath.bezierPath;
        [checkPath moveToPoint: CGPointMake(0.30435 * w, 0.60870 * h)];
        [checkPath addLineToPoint: CGPointMake(0.52539 * w, 0.75528 * h)];
        [checkPath addLineToPoint: CGPointMake(0.75701 * w, 0.28871 * h)];
        
        path = checkPath.CGPath;
    }
    
    return path;
}

- (CGPathRef)folderCheckPath
{
    //static
    CGPathRef path = NULL;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    CGRect frame2 = CGRectMake(floor(w * 0.75510 + 0.5), floor(h * 0.41969 + 0.5),
                               floor(w * 1.08163 + 0.5) - floor(w * 0.75510 + 0.5),
                               floor(h * 0.75130 + 0.5) - floor(h * 0.41969 + 0.5));
    
    _layerFolderCheck.frame = frame2;
    
    if( path == NULL )
    {
        w = frame2.size.width;
        h = frame2.size.height;
        
        UIBezierPath* checkPath = UIBezierPath.bezierPath;
        [checkPath moveToPoint: CGPointMake(0.96364 * w, 0.50000 * h)];
        [checkPath addCurveToPoint: CGPointMake(0.50000 * w, 0.03636 * h) controlPoint1: CGPointMake(0.96364 * w, 0.24394 * h) controlPoint2: CGPointMake(0.75606 * w, 0.03636 * h)];
        [checkPath addCurveToPoint: CGPointMake(0.03636 * w, 0.50000 * h) controlPoint1: CGPointMake(0.24394 * w, 0.03636 * h) controlPoint2: CGPointMake(0.03636 * w, 0.24394 * h)];
        [checkPath addCurveToPoint: CGPointMake(0.50000 * w, 0.96364 * h) controlPoint1: CGPointMake(0.03636 * w, 0.75606 * h) controlPoint2: CGPointMake(0.24394 * w, 0.96364 * h)];
        [checkPath addCurveToPoint: CGPointMake(0.96364 * w, 0.50000 * h) controlPoint1: CGPointMake(0.75606 * w, 0.96364 * h) controlPoint2: CGPointMake(0.96364 * w, 0.75606 * h)];
        [checkPath closePath];
        [checkPath moveToPoint: CGPointMake(0.42845 * w, 0.75336 * h)];
        [checkPath addLineToPoint: CGPointMake(0.67273 * w, 0.50909 * h)];
        [checkPath addLineToPoint: CGPointMake(0.42845 * w, 0.26482 * h)];
        
        path = checkPath.CGPath;
    }
    
    return path;
}

- (CGPathRef)folderOutPath
{
    //static
    CGPathRef path = NULL;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    _layerFolderOut.frame = CGRectMake(0, 0, w, h);
    
    if( path == NULL )
    {
        UIBezierPath* folderPath = UIBezierPath.bezierPath;
        [folderPath moveToPoint: CGPointMake(0.98728 * w, 0.41008 * h)];
        [folderPath addLineToPoint: CGPointMake(0.98732 * w, 0.32052 * h)];
        [folderPath addLineToPoint: CGPointMake(0.98738 * w, 0.20008 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.97036 * w, 0.15915 * h) controlPoint1: CGPointMake(0.98739 * w, 0.18464 * h) controlPoint2: CGPointMake(0.98171 * w, 0.17113 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.92836 * w, 0.14176 * h) controlPoint1: CGPointMake(0.95901 * w, 0.14757 * h) controlPoint2: CGPointMake(0.94501 * w, 0.14177 * h)];
        [folderPath addLineToPoint: CGPointMake(0.36478 * w, 0.14150 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.35155 * w, 0.11911 * h) controlPoint1: CGPointMake(0.36365 * w, 0.14034 * h) controlPoint2: CGPointMake(0.35911 * w, 0.13262 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.32318 * w, 0.08011 * h) controlPoint1: CGPointMake(0.34398 * w, 0.10559 * h) controlPoint2: CGPointMake(0.33452 * w, 0.09246 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.28496 * w, 0.06156 * h) controlPoint1: CGPointMake(0.31183 * w, 0.06775 * h) controlPoint2: CGPointMake(0.29896 * w, 0.06157 * h)];
        [folderPath addLineToPoint: CGPointMake(0.07149 * w, 0.06146 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.02946 * w, 0.07881 * h) controlPoint1: CGPointMake(0.05483 * w, 0.06145 * h) controlPoint2: CGPointMake(0.04120 * w, 0.06724 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.01241 * w, 0.11972 * h) controlPoint1: CGPointMake(0.01810 * w, 0.09039 * h) controlPoint2: CGPointMake(0.01242 * w, 0.10390 * h)];
        [folderPath addLineToPoint: CGPointMake(0.01232 * w, 0.31968 * h)];
        [folderPath addLineToPoint: CGPointMake(0.01223 * w, 0.53702 * h)];
        [folderPath addLineToPoint: CGPointMake(0.01208 * w, 0.87672 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.02909 * w, 0.91764 * h) controlPoint1: CGPointMake(0.01207 * w, 0.89216 * h) controlPoint2: CGPointMake(0.01774 * w, 0.90567 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.07109 * w, 0.93504 * h) controlPoint1: CGPointMake(0.04044 * w, 0.92923 * h) controlPoint2: CGPointMake(0.05444 * w, 0.93503 * h)];
        [folderPath addLineToPoint: CGPointMake(0.92800 * w, 0.93543 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.97003 * w, 0.91808 * h) controlPoint1: CGPointMake(0.94466 * w, 0.93544 * h) controlPoint2: CGPointMake(0.95829 * w, 0.92965 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.98708 * w, 0.87717 * h) controlPoint1: CGPointMake(0.98176 * w, 0.90650 * h) controlPoint2: CGPointMake(0.98707 * w, 0.89300 * h)];
        [folderPath addLineToPoint: CGPointMake(0.98713 * w, 0.75711 * h)];
        [folderPath moveToPoint: CGPointMake(0.01271 * w, 0.30695 * h)];
        [folderPath addCurveToPoint: CGPointMake(0.98544 * w, 0.30739 * h) controlPoint1: CGPointMake(0.98547 * w, 0.30739 * h) controlPoint2: CGPointMake(0.98544 * w, 0.30739 * h)];
     
        path = folderPath.CGPath;
    }
    
    return path;
}

- (void)playCheckFinishAnimation
{
    _layerCheck.hidden = NO;
    _layerOval.hidden = NO;
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        _layerOut.transform = CATransform3DIdentity;
        _layerIn.transform = CATransform3DIdentity;
        _layerOval.transform = CATransform3DIdentity;
        _layerCheck.transform = CATransform3DIdentity;
    }];
    
    [CATransaction setAnimationDuration:1.3];
    
    CATransform3D mtx = CATransform3DMakeScale(1.15, 1.15, 1.0);
    
    _layerOut.transform = mtx;
    _layerIn.transform = mtx;
    _layerOval.transform = mtx;
    _layerCheck.transform = mtx;
    _layerCheck.strokeEnd = 1.0f;
    
    [CATransaction commit];
    _iconType = IconFSTypeFileFinished;
}

- (void)playFolderCloseAnimation
{
    [self rotateFolderCheckToAngle:0];
    _iconType = IconFSTypeFolderClosed;
}

- (void)playFolderOpenAnimation
{
    [self rotateFolderCheckToAngle:90];
    _iconType = IconFSTypeFolderOpened;
}

- (void)rotateFolderCheckToAngle:(CGFloat)angleDegrees
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.4];
    
    [CATransaction setCompletionBlock:^{
        _layerFolderOut.transform = CATransform3DIdentity;
    }];
    
    _layerFolderOut.transform = CATransform3DMakeScale(1.1, 1.1, 1);
    _layerFolderCheck.transform = CATransform3DMakeRotation((angleDegrees * M_PI)/180.0f, 0, 0, 1);
    
    [CATransaction commit];
}


@end
