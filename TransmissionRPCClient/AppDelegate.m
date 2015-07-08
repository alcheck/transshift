//
//  AppDelegate.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalConsts.h"
#import "RPCServerConfigDB.h"
#import "RPCConnector.h"
#import "ServerListController.h"
#import "ChooseServerToAddTorrentController.h"
#import "TorrentListController.h"

#import "FSDirectory.h"

@interface AppDelegate() <RPCConnectorDelegate>

@end

@implementation AppDelegate

{
    ServerListController *_serverList;
    NSData *_torrentFileDataToAdd;
    UINavigationController *_chooseNav;
    RPCServerConfig *_selectedConfig;
    
    NSString *_magnetURLString;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Load db config
    [[RPCServerConfigDB sharedDB] loadDB];

    _serverList = instantiateController( CONTROLLER_ID_SERVERLIST );
       
    UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:_serverList];
    
    UIViewController *rootController = leftNav;
    
    // create split view controller on iPad
    if( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
        TorrentListController *trc = instantiateController( CONTROLLER_ID_TORRENTLIST );
        trc.infoMessage = @"There is no selected server. Select server from list of servers.";
        trc.title = @"Transmission remote client";
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

// this method is launched when user selects a torrent file to process
// after this will be launced ApplicationFinishedWithOptions
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // handle url - it is a .torrent file or magnet url
    if( url )
    {
        
         //NSLog(@"URL Scheme: %@, desc:%@", url.scheme, url );
        _torrentFileDataToAdd = nil;
        _magnetURLString = nil;
        
        if( ![url.scheme isEqualToString:@"magnet"] )
        {
            _torrentFileDataToAdd = [NSData dataWithContentsOfURL:url];
        }
        else
        {
            _magnetURLString = url.description;
        }
        
        if( [RPCServerConfigDB sharedDB].db.count > 0 &&
           ( _torrentFileDataToAdd || _magnetURLString )  )
        {
            // presenting view controller to choose from several remote servers
            ChooseServerToAddTorrentController *chooseServerController = instantiateController( CONTROLLER_ID_CHOOSESERVER );
            
            NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
            byteFormatter.allowsNonnumericFormatting = NO;
            
            chooseServerController.headerInfoMessage = _magnetURLString ?
                [NSString stringWithFormat: @"Add torrent with magnet link:\n%@", _magnetURLString] :
                [NSString stringWithFormat: @"Add torrent with file size: %@", [byteFormatter stringFromByteCount:_torrentFileDataToAdd.length]];
            
            UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(dismissChooseServerController)];
            
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"OK"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(addTorrentToSelectedServer)];
            
            chooseServerController.navigationItem.leftBarButtonItem = leftButton;
            chooseServerController.navigationItem.rightBarButtonItem = rightButton;
            
            
            _chooseNav = [[UINavigationController alloc] initWithRootViewController:chooseServerController];
            _chooseNav.modalPresentationStyle = UIModalPresentationFormSheet;            
            
            [self.window.rootViewController presentViewController:_chooseNav animated:YES completion:nil];
        }
        else    // show message
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"There is no servers avalable"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    
    return YES;
}

- (void)addTorrentToServerWithRPCConfig:(RPCServerConfig*)config priority:(int)priority startNow:(BOOL)startNow
{
    RPCConnector *connector = [[RPCConnector alloc] initWithConfig:config andDelegate:self];
    
    if( _torrentFileDataToAdd )
        [connector addTorrentWithData:_torrentFileDataToAdd priority:priority startImmidiately:startNow];
    else if( _magnetURLString )
        [connector addTorrentWithMagnet:_magnetURLString priority:priority startImmidiately:startNow];
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
    ChooseServerToAddTorrentController *csc = (ChooseServerToAddTorrentController*)_chooseNav.viewControllers[0];
    
    [self addTorrentToServerWithRPCConfig:csc.rpcConfig priority:csc.bandwidthPriority startNow:csc.startImmidiately];
    
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
