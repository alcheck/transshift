//
//  MagnetURLViewController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 03.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "MagnetURLViewController.h"

@interface MagnetURLViewController ()

@end

@implementation MagnetURLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.textMagnetLink.layer.borderWidth = 1.0f;
    //self.textMagnetLink.layer.borderColor = [UIColor darkGrayColor].CGColor;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *copyToBufferBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Copy to buffer", nil )
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(copyToBuffer:)];
    
    self.toolbarItems = @[spacer, copyToBufferBtn, spacer];
    self.navigationController.toolbarHidden = NO;
}

- (void)copyToBuffer:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = self.textMagnetLink.text;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.textMagnetLink.text = _urlString;
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    self.textMagnetLink.text = urlString;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

@end
