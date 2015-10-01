//
//  TorrentListProgressView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 01.10.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListProgressView.h"

@implementation TorrentListProgressView

- (void)setDownloadedProgress:(NSNumber *)downloadedProgress
{
    //if( downloadedProgress != _downloadedProgress )
    //    [self setNeedsDisplay];
    
    _downloadedProgress = downloadedProgress;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if( _downloadedProgress )
    {
//        CGFloat f = _downloadedProgress.floatValue;
//        
//        CGRect r = self.bounds;
//        
//        //r.origin.x = ceil( f * r.size.width - 2 );
//        //r.size.width = 4;
//        
//        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:1];
//        
//        [[UIColor lightGrayColor] setFill];
//        [path fill];
//        
//        [[UIColor darkGrayColor] setStroke];
//        [path stroke];
    }
}

@end
