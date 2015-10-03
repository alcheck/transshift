//
//  TorrentListProgressView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 01.10.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListProgressView.h"

@interface OverlayView : UIView
@end

@implementation OverlayView

-(void)drawRect:(CGRect)rect
{
    CGRect r = self.bounds;
    r.origin.x = r.size.width - 1;
    r.size.width = 1;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:r];
    
    [UIColor.blackColor setFill];
    [path fill];
}

@end


@implementation TorrentListProgressView

{
    OverlayView *_overlayView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _overlayView = [[OverlayView alloc] initWithFrame:CGRectZero];
    _overlayView.hidden = YES;
    _overlayView.opaque = NO;
    _overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0.3];
    
    [self addSubview:_overlayView];
}

- (void)setDownloadedProgress:(NSNumber *)downloadedProgress
{
    if( downloadedProgress == _downloadedProgress )
        return;
    
    _downloadedProgress = downloadedProgress;
    
    CGFloat f = _downloadedProgress.floatValue;
    _overlayView.hidden = ( f <= 0 || f >= 1.0 );
    
    if( !_overlayView.hidden )
    {
        CGRect r = self.bounds;
        
        r.size.width = floor( f * r.size.width - 2 );
        _overlayView.frame = r;
    }
}

@end
