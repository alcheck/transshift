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

- (int)allCount
{
    return (int)_items.count;
}

- (int)downloadCount
{
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isDownloading )
            count++;
    
    return count;
}

- (int)seedCount
{
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isSeeding )
            count++;
    
    return count;
}

- (int)stopCount
{
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isStopped )
            count++;
    
    return count;
}

- (int)checkCount
{
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isChecking )
            count++;
    
    return count;
}

- (int)activeCount
{
    int count = 0;
    for (TRInfo *info in _items )
        if( info.downloadRate > 0 || info.uploadRate > 0 )
            count++;
    
    return count;
}

- (int)errorCount
{
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isError )
            count++;
    
    return count;
}

- (NSString *)totalUploadRateString
{
    long long c = 0;
    
    for( TRInfo* info in _items )
        c += info.uploadRate;
    
    if( c == 0 )
        return @"0 KB/s";
    
    NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
    byteFormatter.allowsNonnumericFormatting = NO;
    
    return [NSString stringWithFormat:@"%@/s", [byteFormatter stringFromByteCount:c]];
}

- (NSString *)totalDownloadRateString
{
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadRate;
    
    if( c == 0 )
        return @"0 KB/s";
    
    NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
    byteFormatter.allowsNonnumericFormatting = NO;

    return [NSString stringWithFormat:@"%@/s", [byteFormatter stringFromByteCount:c]];
}

- (NSString *)totalDownloadSizeString
{
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadedSize;
    
    NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
    byteFormatter.allowsNonnumericFormatting = NO;
    
    return [NSString stringWithFormat:@"%@/s", [byteFormatter stringFromByteCount:c]];
}

- (NSString *)totalUploadSizeString
{
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.uploadedEver;
    
    NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
    byteFormatter.allowsNonnumericFormatting = NO;
    
    return [NSString stringWithFormat:@"%@/s", [byteFormatter stringFromByteCount:c]];
}

- (NSArray *)allTorrents
{
    return _items;
}

- (NSArray*)filterWithPredicateString:(NSString*)filterString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
    return [_items filteredArrayUsingPredicate:predicate];
}

- (NSArray *)seedingTorrents
{
    return [self filterWithPredicateString:@"isSeeding == YES"];
}

- (NSArray *)downloadingTorrents
{
    return [self filterWithPredicateString:@"isDownloading == YES"];
}

- (NSArray *)checkingTorrents
{
    return [self filterWithPredicateString:@"isChecking == YES"];
}

- (NSArray *)stoppedTorrents
{
    return [self filterWithPredicateString:@"isStopped == YES"];
}

- (NSArray *)errorTorrents
{
    return [self filterWithPredicateString:@"isError == YES"];
}

- (NSArray *)activeTorrents
{
    return [self filterWithPredicateString:@"downloadRate > 0 OR uploadRate > 0"];
}

@end
