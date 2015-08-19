//
//  iconView.h
//  IconTestApp
//
//  Created by Alexey Chechetkin on 18.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, IconFSType)
{
    IconFSTypeFile,
    IconFSTypeFileFinished,
    IconFSTypeFolderClosed,
    IconFSTypeFolderOpened,
    IconFSTypeNone
};


@interface IconFS : UIView

@property(nonatomic) IconFSType iconType;
@property(nonatomic) CGFloat    downloadProgress;

- (void)playCheckFinishAnimation;

- (void)playFolderOpenAnimation;

- (void)playFolderCloseAnimation;

@end
