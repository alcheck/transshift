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
#import "ServerListFooterView.h"
#import "GlobalConsts.h"

@interface ServerListController () <ServerListItemCellDelegate>

@property (strong, nonatomic) RPCServerConfigController *rpcConfigController;

@end

@implementation ServerListController

{
    UIBarButtonItem *_buttonDone;
    UIBarButtonItem *_buttonEdit;
    UIBarButtonItem *_buttonAdd;
    
    StatusListController *_statusListController;
    
    NSString        *_version;
    
    ServerListFooterView *_footerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = SERVERLIST_CONTROLLER_TITLE;
       
     // predefine buttons
    _buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(toggleEditMode)];
    
    _buttonEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                target:self
                                                                action:@selector(toggleEditMode)];
    
    _buttonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                               target:self
                                                               action:@selector(showAddNewRPCConfigController)];
    
    self.navigationItem.leftBarButtonItem = _buttonEdit;
    self.navigationItem.rightBarButtonItem = _buttonAdd;
    
    // show version
    _version = [NSString stringWithFormat: NSLocalizedString(@"version %@(%@)", "ServerListController version"),
                         [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
                         [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
    
    //self.footerInfoMessage = _version;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_statusListController stopUpdating];
    _statusListController = nil;

    // fixing left button title for popOver navigation bar
    if( self.splitViewController )
    {
        UINavigationController *nav = self.splitViewController.viewControllers[1];
        TorrentListController *tlc = nav.viewControllers[0];
        
        tlc.items = nil;
        tlc.infoMessage = NSLocalizedString( @"There is no selected server.", @"" );
        tlc.errorMessage = nil;
        tlc.footerInfoMessage = nil;
        tlc.popoverButtonTitle = SERVERLIST_CONTROLLER_TITLE;
        
        [nav popToRootViewControllerAnimated:YES];
    }
    
    // - BACKGOUND FETCHING remove keys for background fetching
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USERDEFAULTS_BGFETCH_KEY_RPCCONFG];
    [defaults removeObjectForKey:USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS];
    // ---
}

- (RPCServerConfigController *)rpcConfigController
{
    if( !_rpcConfigController )
    {
        _rpcConfigController = instantiateController(CONTROLLER_ID_RPCSERVERCONFIG);
    
        // add buttons
        _rpcConfigController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Cancel", @"")
                                                                                                 style:UIBarButtonItemStyleDone
                                                                                                target:self
                                                                                                action:@selector(hideRPCConfigController)];
    }
    
    return _rpcConfigController;
}

- (void)toggleEditMode
{
    BOOL editing = !self.tableView.editing;
    [self.tableView setEditing:editing animated:YES];
    self.navigationItem.leftBarButtonItem = editing ? _buttonDone : _buttonEdit;
}

- (void)showAddNewRPCConfigController
{  
    // show view controller with two buttons "Cancel and Save"
    self.rpcConfigController.title =  NSLocalizedString(@"Add new server", @"");
    self.rpcConfigController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                                  initWithTitle: NSLocalizedString(@"Add", @"")
                                                                  style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(addNewRPCConfig)];
    
    [self.navigationController pushViewController:self.rpcConfigController animated:YES];
}

- (void)hideRPCConfigController
{
    [self.navigationController popViewControllerAnimated:YES];
    _rpcConfigController = nil;
}

- (void)addNewRPCConfig
{
    if( [self.rpcConfigController saveConfig] )
    {
        // add new item to the db, reload data, hide controller
        [[RPCServerConfigDB sharedDB].db addObject:self.rpcConfigController.config];
        [[RPCServerConfigDB sharedDB] saveDB];
        
        NSUInteger count = [RPCServerConfigDB sharedDB].db.count;
        
        //[self.tableView reloadData];
        [self hideRPCConfigController];
        
        [self.tableView beginUpdates];
        
        if( count > 1 )
            [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:(count-1) inSection:0] ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        else
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
}

// save editted RPC config
- (void)commitEditingRPCConfig
{
    if( [self.rpcConfigController saveConfig] )
    {
        [[RPCServerConfigDB sharedDB] saveDB];
        [self.tableView reloadData];
        [self hideRPCConfigController];
    }
}

// handler for editing
- (void)editButtonTouched:(UISegmentedControl *)button atPath:(NSIndexPath *)indexPath
{
     RPCServerConfig *configToEdit = [RPCServerConfigDB sharedDB].db[indexPath.row];
    
    self.rpcConfigController.title =  NSLocalizedString(@"Edit server", @"RPCConfigController title");
    self.rpcConfigController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                                  initWithTitle: NSLocalizedString(@"Save", @"")
                                                                  style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(commitEditingRPCConfig)];
    
    self.rpcConfigController.config = configToEdit;
    
    [self toggleEditMode];
    
    [self.navigationController pushViewController:self.rpcConfigController animated:YES];
}

- (void)showVersion:(NSString *)version
{
   if( version )
   {
       if( !_footerView )
           _footerView = [ServerListFooterView view];
       
       _footerView.labelVersion.text = version;
       self.tableView.tableFooterView = _footerView;
   }
   else
   {
       self.tableView.tableFooterView = nil;
   }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if( self.tableView.tableFooterView )
    {
        [_footerView setBoundsFromTableView:self.tableView];
        self.tableView.tableFooterView = _footerView;
        
        if( self.splitViewController )
        {
            UINavigationController *nav = self.splitViewController.viewControllers[1];
            TorrentListController *tlc = nav.viewControllers[0];
            
            tlc.items = nil;
            tlc.infoMessage = NSLocalizedString( @"There is no selected server.", @"" );
        }
    }
}

#pragma mark - TableView delegate methods

// handler for selecting server with config
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _statusListController = instantiateController(CONTROLLER_ID_TORRENTSSTATUSLIST);
    
    RPCServerConfig *selectedConfig = [RPCServerConfigDB sharedDB].db[indexPath.row];
    
    // - BACKGROUND FETCHING register config for background fetchig
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedConfig.plist forKey:USERDEFAULTS_BGFETCH_KEY_RPCCONFG];
    // -
    
    _statusListController.config = selectedConfig ;
    _statusListController.title = selectedConfig.name;
    
    [self.navigationController pushViewController:_statusListController animated:YES];
}

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
    NSUInteger itemsCount = [RPCServerConfigDB sharedDB].db.count;

    self.navigationItem.leftBarButtonItem.enabled = itemsCount > 0;
    self.infoMessage = itemsCount > 0 ? nil :  NSLocalizedString(@"There are no servers available add server to the list", nil);
    
    // show version if there is some server items
    //self.footerInfoMessage = itemsCount > 0 ?  [_version : nil;
    [self showVersion:(itemsCount > 0 ? _version : nil )];
    
    return itemsCount > 0 ? 1 : 0;
 }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"List of configured servers", @"section title");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        // perform delete of the item
        [[RPCServerConfigDB sharedDB].db removeObjectAtIndex:indexPath.row ];
        [[RPCServerConfigDB sharedDB] saveDB];
        
        NSUInteger count = [RPCServerConfigDB sharedDB].db.count;
        
        [tableView beginUpdates];
        
        if( count > 0 )
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        else
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:0]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [RPCServerConfigDB sharedDB].db.count;
}


@end

