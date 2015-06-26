//
//  TorrentListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentListController.h"

@interface TorrentListController () 

@end

@implementation TorrentListController

{
    UILabel *_backgroundLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setBackgroundTitle:(NSString *)backgroundTitle
{
    if( !_backgroundLabel )
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:19];
        label.numberOfLines = 0;
        _backgroundLabel = label;
        self.tableView.backgroundView = _backgroundLabel;
    }
    
    _backgroundLabel.text = backgroundTitle;
}

#pragma mark - UISplitViewControllerDelegate methods

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.popoverButtonTitle;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if( self.navigationItem.leftBarButtonItem == barButtonItem )
        self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

@end
