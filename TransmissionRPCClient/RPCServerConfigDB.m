//
//  RPCServerConfigDB.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "RPCServerConfigDB.h"


@interface RPCServerConfigDB()

@property (nonatomic,readonly) NSString *dbFileName;

@end

// singlton for getting rpc data config
@implementation RPCServerConfigDB

{
    NSMutableArray *_configData;
}

// returns shared instance of config
+ (RPCServerConfigDB*)sharedDB
{
    static RPCServerConfigDB* _inst = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[RPCServerConfigDB alloc] initPrivate];
    });
    
    return _inst;
}

// closed init method
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"RPCServerConfigDB singlton" reason:@"RPCServerConfigDB : user singlton methods" userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    if( self )
    {
        _configData = [NSMutableArray array];
    }
    
    return self;
}

- (NSMutableArray *)db
{
    return _configData;
}

- (NSString*)dbFileName
{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[arr firstObject] stringByAppendingPathComponent:@"RPCServerConfigDB"];
}

- (void)loadDB
{
    NSString *filePath = self.dbFileName;
    _configData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!_configData)
    {
        //NSLog( @"RPCServerConfigDB: Can't load db at path: %@", filePath );
        _configData = [NSMutableArray array];
    }
}

- (void)saveDB
{
    NSString *filePath = self.dbFileName;
    if( ![NSKeyedArchiver archiveRootObject:_configData toFile:filePath] )
    {
        //NSLog( @"RPCServerConfigDB: Can't save db at path: %@", filePath );
    }
}

@end
