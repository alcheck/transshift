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
#import "InfoMessage.h"

#import "FSDirectory.h"

@interface AppDelegate() <RPCConnectorDelegate>

@property(atomic) TRInfos*  bgTRInfos;

@end

@implementation AppDelegate

{
    ServerListController *_serverList;
    NSData *_torrentFileDataToAdd;
    UINavigationController *_chooseNav;
    RPCServerConfig *_selectedConfig;
    
    NSString *_magnetURLString;
    
    // flag showing - that we use background fetching
    BOOL _isBackgroundFetching;
    
    // background fetch complition handler
    void (^_bgComplitionHandler)(UIBackgroundFetchResult);
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
    // set background fetch interval
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
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


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _isBackgroundFetching = NO;
}

- (void)addTorrentToServerWithRPCConfig:(RPCServerConfig*)config priority:(int)priority startNow:(BOOL)startNow
{
    RPCConnector *connector = [[RPCConnector alloc] initWithConfig:config andDelegate:self];
    
    if( _torrentFileDataToAdd )
        [connector addTorrentWithData:_torrentFileDataToAdd priority:priority startImmidiately:startNow];
    else if( _magnetURLString )
        [connector addTorrentWithMagnet:_magnetURLString priority:priority startImmidiately:startNow];
}

- (void)gotTorrentAdded
{
    InfoMessage *msg = [InfoMessage infoMessageWithSize:CGSizeMake(300, 50)];
    [msg showInfo:@"New torrent has been added" fromView:self.window.rootViewController.view];
}

// error handler
- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    if( !_isBackgroundFetching )
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't add torrent"
                                                        message:[NSString stringWithFormat:@"%@", errorMessage]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSLog(@"BackgroundFetch: connector request error, %@", errorMessage);
        _bgComplitionHandler(UIBackgroundFetchResultFailed);
    }
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
    // Save db changes
    [[RPCServerConfigDB sharedDB] saveDB];
    
    // Save settings changes
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
}

- (void)gotAllTorrents:(TRInfos *)trInfos
{
    if( _isBackgroundFetching )
    {
        NSLog(@"BackgroundFetch: got all torrents");
        
        // fetch is complite
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *downIds = [defaults arrayForKey:USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS];

        // update current downloading torrents ids
        // in NSUserDefaults
        NSArray *curDownIds = trInfos.downloadingTorrents;
        
        NSLog(@"curDownIds from NsUserDefaults: %i", (int)curDownIds.count );
        
        if( curDownIds && curDownIds.count > 0 )
        {
            NSLog(@"Updating NsUserDefaults with curDownIds ...");
            
            NSMutableArray *downIds = [NSMutableArray array];
            
            for ( TRInfo* t in curDownIds )
                [downIds addObject:@(t.trId)];
            
            NSLog( @"Setting updated array with Ids count :%i", (int)downIds.count );
            [defaults setObject:downIds forKey:USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS];
            [defaults synchronize];
        }
        else // there is no ids, remove key
        {
            [defaults removeObjectForKey:USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS];
            [defaults synchronize];
        }
        
        
        if( !downIds )
        {
            NSLog(@"No previous downloading torrent ids found. Exit");
            // there is downIds - try to create new and return
            _bgComplitionHandler(UIBackgroundFetchResultNoData);
        }
        else
        {
            NSLog(@"There are downloading torrents, %i ", (int)downIds.count);
            // info string
            NSMutableString *infoStr = [NSMutableString string];
            
            // searching finished torrents
            NSArray* seedTrs = trInfos.seedingTorrents;
            for ( NSNumber* trId in downIds )
            {
                int torrentId = [trId intValue];
                
                for( TRInfo* info in seedTrs )
                {
                    if( torrentId == info.trId )
                    {
                        // we have found torrent that is finished
                        [infoStr appendString: [NSString stringWithFormat:@"Torrent: %@, has finished downloading\n", info.name] ];
                    }
                }
            } // end for searching
            
            if( infoStr.length > 0 )
            {
                NSLog(@"Found finished torrents: %@", infoStr);
                // we should show
                // show local notification
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                
                /* supported only on iOS > 8.1
                notification.alertTitle = @"Torrent(s) downloaded";
                */
                
                notification.alertBody = infoStr;
                notification.soundName = UILocalNotificationDefaultSoundName;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                _bgComplitionHandler(UIBackgroundFetchResultNewData);
            }
            else
            {
                NSLog(@"No finished torrents found. Exit.");
                _bgComplitionHandler(UIBackgroundFetchResultNoData);
            }
        }
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
//    // just for test
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.alertBody = @"Background fetch!";
//    [application presentLocalNotificationNow:notification];
//    
    
    // peform fetch in background
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *plist = [defaults dictionaryForKey: USERDEFAULTS_BGFETCH_KEY_RPCCONFG];
    
    if( plist )
    {
        NSLog(@"BackgroundFetch: - GETTING DATA .... ");
        
        RPCServerConfig *config = [[RPCServerConfig alloc] initFromPList:plist];
        // try to get update on this torrents
        
        self.bgTRInfos = nil;
        // set request timeout max to 5 seconds
        config.requestTimeout = 5;
        RPCConnector *connector = [[RPCConnector alloc] initWithConfig:config andDelegate:self];
        _isBackgroundFetching = YES;
        _bgComplitionHandler = completionHandler;
        // try to get all torrents
        [connector getAllTorrents];
    }
    else
    {
        NSLog(@"BackgroundFetch: - NO DATA FETCHED");
        completionHandler( UIBackgroundFetchResultNoData );
    }
}


@end
