//
//  FileListTouchAreaView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "FileListTouchAreaView.h"

@interface FileListTouchAreaView() <UIAlertViewDelegate>

@end

@implementation FileListTouchAreaView

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return ( action == @selector(copy:) || action == @selector(renameAction:) );
}

- (void)copy:(id)sender
{
    if( _itemPath )
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:_itemPath];
    }
}

- (void)renameAction:(id)sender
{
    if( _delegate )
    {
        // perform some custom action
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_isFile ?
                              NSLocalizedString(@"AlertRenameFileTitle",  nil) : NSLocalizedString(@"AlertRenameFolderTitle", nil)
                                                        message:_isFile ?
                              NSLocalizedString(@"AlertRenameFileText", nil) : NSLocalizedString(@"AlertRenameFolderText", nil)
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Rename", nil), nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = _itemName;
        alert.delegate = self;
        
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex != alertView.cancelButtonIndex && _delegate )
    {
        // perform some action
        if( [_delegate respondsToSelector:@selector(renameFileOrFolder:fromOldName:toNewName:)] )
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *newName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            //NSString *newPath = [_itemPath stringByReplacingOccurrencesOfString:_itemName withString:newName];
            
            // make new names
            [_delegate renameFileOrFolder:_isFile fromOldName:_itemPath toNewName:newName];
        }
    }
}

@end
