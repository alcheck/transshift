//
//  TorrentListProgressView.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 01.10.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TorrentListProgressView : UIProgressView

/// set downloaded progress from 0 to 1
@property( nonatomic ) NSNumber *downloadedProgress;

@end
