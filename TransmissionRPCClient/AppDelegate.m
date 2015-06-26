//
//  AppDelegate.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "AppDelegate.h"
#import "RPCServerConfigDB.h"
#import "ServerListController.h"
#import "TorrentListController.h"

@implementation AppDelegate

{
    ServerListController *_serverList;
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


- (void)applicationWillResignActive:(UIApplication *)application
{
    [[RPCServerConfigDB sharedDB] saveDB];
}

@end
