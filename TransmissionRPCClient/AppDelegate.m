//
//  AppDelegate.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "AppDelegate.h"
#import "RPCServerConfigDB.h"
#import "RPCConnector.h"
#import "ServerListController.h"
#import "ChooseServerToAddTorrentController.h"
#import "TorrentListController.h"

@interface AppDelegate() <UIAlertViewDelegate, RPCConnectorDelegate>

@end

@implementation AppDelegate

{
    ServerListController *_serverList;
    NSData *_torrentFileDataToAdd;
    UINavigationController *_chooseNav;
    RPCServerConfig *_selectedConfig;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Load db config
    [[RPCServerConfigDB sharedDB] loadDB];
    
    // test RPC Config controller
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
    _serverList = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_SERVERLIST];
       
    UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:_serverList];
    
    UIViewController *rootController = leftNav;
    
    // create split view controller on iPad
    if( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
        TorrentListController *trc = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_TORRENTLIST];
        trc.backgroundTitle = @"There is no selected server. Select server from list of servers.";
        trc.navigationItem.title = @"Transmission remote client";
        trc.popoverButtonTitle = SERVERLIST_CONTROLLER_TITLE;
        
        UINavigationController *rightNav = [[UINavigationController alloc] initWithRootViewController:trc];
        
        UISplitViewController *splitView = [[UISplitViewController alloc] init];
        splitView.viewControllers = @[ leftNav, rightNav ];
        splitView.delegate = trc;
        rootController = splitView;
    }
    self.window.rootViewController = rootController;
    // show main window
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // handle url
    if( url )
    {
        _torrentFileDataToAdd = [NSData dataWithContentsOfURL:url];
        //NSLog(@"File data containted: %lu bytes", (unsigned long)_torrentFileDataToAdd.length);
        
        if( _torrentFileDataToAdd )
        {
            if( [RPCServerConfigDB sharedDB].db.count > 0 )
            {
               if( [RPCServerConfigDB sharedDB].db.count == 1 )
               {
                   // add to default server
                   _selectedConfig = [RPCServerConfigDB sharedDB].db[0];
                   //[self addTorrentToServerWithRPCConfig:config];
                   
                   // show alert to choose
                   UIAlertView *alert = [[UIAlertView alloc]
                                        initWithTitle:@"Adding torrent"
                                        message:[NSString stringWithFormat:@"Add torrent to server %@ ?", _selectedConfig.name]
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"OK", nil];
                   
                   [alert show];
               }
               else
               {
                   // presenting view controller to choose from several remote servers
                   UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
                   ChooseServerToAddTorrentController *chooseServerController = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_CHOOSESERVER];
                   
                   UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissChooseServerController)];
                   UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(addTorrentToSelectedServer)];
                   
                   chooseServerController.navigationItem.leftBarButtonItem = leftButton;
                   chooseServerController.navigationItem.rightBarButtonItem = rightButton;
                   
                   _chooseNav = [[UINavigationController alloc] initWithRootViewController:chooseServerController];
                   _chooseNav.modalPresentationStyle = UIModalPresentationFormSheet;
                   
                   [self.window.rootViewController presentViewController:_chooseNav animated:YES completion:nil];
               }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There is no servers avalable" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.cancelButtonIndex != buttonIndex )
    {
        [self addTorrentToServerWithRPCConfig:_selectedConfig];
    }
}

- (void)addTorrentToServerWithRPCConfig:(RPCServerConfig*)config
{
    RPCConnector *connector = [[RPCConnector alloc] initWithConfig:config andDelegate:self];
    [connector addTorrentWithData:_torrentFileDataToAdd];
}

- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't add torrent"
                                                    message:[NSString stringWithFormat:@"%@", errorMessage]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)addTorrentToSelectedServer
{
    RPCServerConfig *config = ((ChooseServerToAddTorrentController*)_chooseNav.viewControllers[0]).selectedRPCConfig;
    [self addTorrentToServerWithRPCConfig:config];
    
    [self dismissChooseServerController];
}

- (void)dismissChooseServerController
{
    [_chooseNav dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[RPCServerConfigDB sharedDB] saveDB];
}

@end
