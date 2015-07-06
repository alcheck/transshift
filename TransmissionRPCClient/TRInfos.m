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

- (NSString *)totalUploadRateString
{
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.uploadRate;
    
//    if( c == 0 )
//        return @"-";
    
    NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
    byteFormatter.allowsNonnumericFormatting = NO;
    
    return [NSString stringWithFormat:@"%@/s", [byteFormatter stringFromByteCount:c]];
}

- (NSString *)totalDownloadRateString
{
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadRate;
//    
//    if( c == 0 )
//        return @"-";
    
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

- (NSArray *)activeTorrents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadRate > 0 OR uploadRate > 0"];
    return [_items filteredArrayUsingPredicate:predicate];
}

@end
