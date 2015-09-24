//
//  InfoMenuLabel.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "InfoMenuLabel.h"

@interface InfoMenuLabel() <UIAlertViewDelegate>

@end

@implementation InfoMenuLabel

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:) || action == @selector(customMenuAction:) );
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.text];
}


- (void)customMenuAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Rename torrent", nil)
                                                    message: NSLocalizedString( @"Set new name of the torrent", nil )
                                                   delegate:self
                                          cancelButtonTitle: NSLocalizedString( @"Cancel", nil )
                                          otherButtonTitles: NSLocalizedString( @"Rename", nil ), nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = self.text;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == alertView.cancelButtonIndex )
        return;
    
    NSString *newName = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if( newName.length > 0 && _delegate && [_delegate respondsToSelector:@selector(InfoMenuLabelSetNewName:)])
    {
        // ok - rename
        [_delegate InfoMenuLabelSetNewName:newName];
    }
}


@end
