//
//  StatusListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 25.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "StatusListController.h"

@interface StatusListController ()

@end

@implementation StatusListController

{
    NSArray *_sections;
    NSArray *_itemNames;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNames];
    
    if( self.config )
        self.navigationItem.title = self.config.name;
}

- (void)initNames
{
    _sections = @[ @"Statuses" ];
    _itemNames = @[ @"All", @"Downloading", @"Seeding", @"Stopped" ];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"torrentStatusCell" forIndexPath:indexPath];
    
    // Configure the cell
    cell.detailTextLabel.text  = @"0";
    cell.textLabel.text = _itemNames[indexPath.row];
    
    return cell;
}

@end
