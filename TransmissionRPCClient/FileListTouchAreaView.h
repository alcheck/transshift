//
//  FileListTouchAreaView.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileListTouchAreaDelegate <NSObject>

@optional - (void)renameFileOrFolder:(BOOL)isFile fromOldName:(NSString *)oldname toNewName:(NSString *)newName;

@end

@interface FileListTouchAreaView : UIView

@property( weak, nonatomic ) id<FileListTouchAreaDelegate> delegate;

@property( nonatomic ) BOOL     isFile;
@property( nonatomic ) NSString *itemName;
@property( nonatomic ) NSString *itemPath;

- (void)renameAction:(id)sender;

@end
