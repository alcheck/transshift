//
//  AppDelegate.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "AppDelegate.h"
#import "RPCServerConfigController.h"

@implementation AppDelegate

{
    RPCServerConfigController *_rpcConfigController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // test RPC Config controller
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
    _rpcConfigController = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_RPCSERVERCONFIG];
    
    // try to load settings
    RPCServerConfig *testConfig = [[RPCServerConfig alloc] init];
    testConfig.name = @"Giga";
    testConfig.host = @"192.168.0.1";
    testConfig.port = 9091;
    testConfig.rpcPath = @"/remote/rpc";
    testConfig.useSSL = YES;
    testConfig.userName = @"Alcheck";
    testConfig.userPassword = @"P@ssw0rd";
    testConfig.refreshTimeout = 3;
    testConfig.requestTimeout = 20;
    
    _rpcConfigController.config = testConfig;
    
    UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:_rpcConfigController];
    self.window.rootViewController = leftNav;
    
    //
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
