//
//  IconHalfCloud.h
//  IconTestApp
//
//  Created by Alexey Chechetkin on 19.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, IconHalfCloudType)
{
    IconHalfCloudTypeUpload,
    IconHalfCloudTypeDownload,
    IconHalfCloudTypeNone
};

@interface IconHalfCloud : UIView

@property(nonatomic) IconHalfCloudType  iconType;
@property(nonatomic, readonly) BOOL     isDownloadAnimationInProgress;
@property(nonatomic, readonly) BOOL     isUploadAnimationInProgress;

- (void)playUploadAnimation;
- (void)stopUploadAnimation;
- (void)playDownloadAnimation;
- (void)stopDownloadAnimation;

@end
