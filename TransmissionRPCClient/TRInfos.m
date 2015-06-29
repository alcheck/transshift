//
//  TRInfos.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 28.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRInfos.h"

@interface TRInfos()

@property(nonatomic) NSMutableArray* items;    // holds trInfo items

@end

@implementation TRInfos

+ (TRInfos *)infosFromArrayOfJSON:(NSArray *)jsonArray
{
    return [[TRInfos alloc] initFromArrayOfJSON:jsonArray];
}

// close init method
- (instancetype)init
{
    self = [super init];
    
    if( self )
    {
        _items = [NSMutableArray array];
    }
    
    return self;
}

// init from array of json objects
- (instancetype)initFromArrayOfJSON:(NSArray*)jsonArray
{
    
    self = [super init];
    
    if( self )
    {
        _items = [NSMutableArray array];
        for( NSDictionary* d in jsonArray )
        {
            [_items addObject: [TRInfo infoFromJSON:d] ];
        }
    }
    
    return self;
}

- (NSUInteger)allCount
{
    return _items.count;
}

- (NSUInteger)downloadCount
{
    NSUInteger count = 0;
    for (TRInfo *info in _items )
        if( info.isDownloading )
            count++;
    return count;
}

- (NSUInteger)seedCount
{
    NSUInteger count = 0;
    for (TRInfo *info in _items )
        if( info.isSeeding )
            count++;
    return count;
}

- (NSUInteger)stopCount
{
    NSUInteger count = 0;
    for (TRInfo *info in _items )
        if( info.isStopped )
            count++;
    return count;
}

- (NSUInteger)checkCount
{
    NSUInteger count = 0;
    for (TRInfo *info in _items )
        if( info.isChecking )
            count++;
    return count;
}

- (NSArray *)allTorrents
{
    return _items;
}

- (NSArray *)seedingTorrents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSeeding == YES"];
    return [_items filteredArrayUsingPredicate:predicate];
}

- (NSArray *)downloadingTorrents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDownloading == YES"];
    return [_items filteredArrayUsingPredicate:predicate];
}

- (NSArray *)checkingTorrents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isChecking == YES"];
    return [_items filteredArrayUsingPredicate:predicate];
}

- (NSArray *)stoppedTorrents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isStopped == YES"];
    return [_items filteredArrayUsingPredicate:predicate];
}

@end
