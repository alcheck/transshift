//
//  TorrentListProgressView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 01.10.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListProgressView.h"

@implementation TorrentListProgressView

{
    UIView *_overlayView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _overlayView = [[UIView alloc] initWithFrame:CGRectZero];
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
