//
//  ServerListController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ServerListController.h"
#import "ServerListItemCell.h"
#import "RPCServerConfigController.h"
#import "TorrentListController.h"
#import "StatusListController.h"
#import "RPCServerConfigDB.h"

@interface ServerListController () <ServerListItemCellDelegate>

@property (strong, nonatomic) RPCServerConfigController *rpcConfigController;

@end

@implementation ServerListController

{
    UIBarButtonItem *_buttonDone;
    UIBarButtonItem *_buttonEdit;
    UIBarButtonItem *_buttonAdd;
    
    StatusListController *_statusListController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = SERVERLIST_CONTROLLER_TITLE;
       
     // predefine buttons
    _buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditMode)];
    _buttonEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditMode)];
    _buttonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddNewRPCConfigController)];
    
    self.navigationItem.leftBarButtonItem = _buttonEdit;
    self.navigationItem.rightBarButtonItem = _buttonAdd;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if( self.splitViewController )
    {
        UINavigationController *nc = self.splitViewController.viewControllers[1];
        TorrentListController *tlc = nc.viewControllers[0];
        if( tlc.navigationItem.leftBarButtonItem )
        {
            tlc.popoverButtonTitle = SERVERLIST_CONTROLLER_TITLE;
            tlc.navigationItem.leftBarButtonItem.title = SERVERLIST_CONTROLLER_TITLE;
        }
    }
}


- (RPCServerConfigController *)rpcConfigController
{
    if( !_rpcConfigController )
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
        _rpcConfigController = [storyBoard instantiateViewControllerWithIdentifier:CONTROLLER_ID_RPCSERVERCONFIG];
    
        // add buttons
        _rpcConfigController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(HideRPCConfigController)];
    }
    
    return _rpcConfigController;
}

- (void)toggleEditMode
{
    BOOL editing = !self.tableView.editing;
    [self.tableView setEditing:editing animated:YES];
    self.navigationItem.leftBarButtonItem = self.tableView.editing ? _buttonDone : _buttonEdit;
}

- (void)showAddNewRPCConfigController
{  
    // show view controller with two buttons "Cancel and Save"
    self.rpcConfigController.navigationItem.title = @"Add new server";
        _rpcConfigController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(AddNewRPCConfig)];
    
    [self.navigationController pushViewController:self.rpcConfigController animated:YES];
}

- (void)AddNewRPCConfig
{
    if( [self.rpcConfigController saveConfig] )
    {
        // add new item to the db, reload data, hide controller
        [[RPCServerConfigDB sharedDB].db addObject:self.rpcConfigController.config];
        [self.tableView reloadData];
        [self HideRPCConfigController];
    }
}

- (void)CommitEditinRPCConfig
{
    if( [self.rpcConfigController saveConfig] )
    {
        [self.tableView reloadData];
        [self HideRPCConfigController];
    }
}

- (void)HideRPCConfigController
{
    [self.navigationController popViewControllerAnimated:YES];
    _rpcConfigController = nil;
}

// handler for editing
- (void)editButtonTouched:(UISegmentedControl *)button atPath:(NSIndexPath *)indexPath
{
     RPCServerConfig *configToEdit = [RPCServerConfigDB sharedDB].db[indexPath.row];
    
    self.rpcConfigController.navigationItem.title = @"Edit server";
    _rpcConfigController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(CommitEditinRPCConfig)];
    
    self.rpcConfigController.config = configToEdit;
    
    [self toggleEditMode];
    
    [self.navigationController pushViewController:self.rpcConfigController animated:YES];
}

// handler for selecting server with config
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
    _statusListController = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_TORRENTSSTATUSLIST];
    _statusListController.config = [RPCServerConfigDB sharedDB].db[indexPath.row];
    
    [self.navigationController pushViewController:_statusListController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_statusListController stopUpdating];
    _statusListController = nil;
}

#pragma mark - Table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SERVERITEM forIndexPath:indexPath];
    RPCServerConfig *config = [RPCServerConfigDB sharedDB].db[indexPath.row];
    
    cell.nameLabel.text = config.name;
    cell.addressLabel.text = config.urlString;
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int itemsCount = [RPCServerConfigDB sharedDB].db.count;
    return itemsCount > 0 ? @"List of configured servers" : nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        // perform delete of the item
        [ [RPCServerConfigDB sharedDB].db removeObjectAtIndex:indexPath.row ];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] ]
         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int itemsCount = [RPCServerConfigDB sharedDB].db.count;
    if( itemsCount == 0 )
    {
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectZero];
        info.textColor = [UIColor darkGrayColor];
        info.font = [UIFont systemFontOfSize:20];
        info.numberOfLines = 0;
        info.textAlignment = NSTextAlignmentCenter;
        info.text = @"There is no servers available. Add server to the list.";
        
        CGRect r = tableView.bounds;
        info.frame = r;
        
        tableView.backgroundView = info;
        
    }
    else
    {
        tableView.backgroundView = nil;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = itemsCount > 0;
    return itemsCount;
}


@end

