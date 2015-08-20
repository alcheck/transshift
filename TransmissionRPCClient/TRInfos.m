//
//  TRInfos.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 28.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRInfos.h"
#import "GlobalConsts.h"

@interface TRInfos()

@property(nonatomic) NSMutableArray* items;    // holds trInfo items

@end

@implementation TRInfos

{
    NSMutableDictionary *_chache;
    long long           _totalUploadRate;
    long long           _totalDownloadRate;
}

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
        _chache = [NSMutableDictionary dictionary];
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
        _chache = [NSMutableDictionary dictionary];
        
        for( NSDictionary* d in jsonArray )
            [_items addObject: [TRInfo infoFromJSON:d] ];
    }
    
    return self;
}

- (int)allCount
{
    return (int)_items.count;
}

#define CHACHE_KEY_DOWNLOADCOUNT @"downloadCount"
- (int)downloadCount
{
    if( _chache[CHACHE_KEY_DOWNLOADCOUNT] )
        return [_chache[CHACHE_KEY_DOWNLOADCOUNT] intValue];
    
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isDownloading )
            count++;
    
    _chache[CHACHE_KEY_DOWNLOADCOUNT] = @(count);
    
    return count;
}

#define CHACHE_KEY_SEEDCOUNT @"seedCount"
- (int)seedCount
{
    if( _chache[CHACHE_KEY_SEEDCOUNT] )
        return [_chache[CHACHE_KEY_SEEDCOUNT] intValue];
    
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isSeeding )
            count++;
    
    _chache[CHACHE_KEY_SEEDCOUNT] = @(count);
    
    return count;
}

#define CHACHE_KEY_STOPCOUNT @"stopCount"
- (int)stopCount
{
    if(_chache[CHACHE_KEY_STOPCOUNT])
        return [_chache[CHACHE_KEY_STOPCOUNT] intValue];
    
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isStopped )
            count++;
    
    _chache[CHACHE_KEY_STOPCOUNT] = @(count);
    
    return count;
}

#define CHACHE_KEY_CHECKCOUNT @"checkCount"
- (int)checkCount
{
    if( _chache[CHACHE_KEY_CHECKCOUNT] )
        return [_chache[CHACHE_KEY_CHECKCOUNT] intValue];
        
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isChecking )
            count++;
    
    _chache[CHACHE_KEY_CHECKCOUNT] = @(count);
    
    return count;
}

#define CHACHE_KEY_ACTIVECOUNT  @"activeCount"
- (int)activeCount
{
    if( _chache[CHACHE_KEY_ACTIVECOUNT] )
        return [_chache[CHACHE_KEY_ACTIVECOUNT] intValue];
    
    int count = 0;
    for (TRInfo *info in _items )
        if( info.downloadRate > 0 || info.uploadRate > 0 )
            count++;
    
    _chache[CHACHE_KEY_ACTIVECOUNT] = @(count);
    
    return count;
}

#define CHACHE_KEY_ERRORCOUNT @"errorCount"
- (int)errorCount
{
    if( _chache[CHACHE_KEY_ERRORCOUNT] )
        return [_chache[CHACHE_KEY_ERRORCOUNT] intValue];
    
    int count = 0;
    for (TRInfo *info in _items )
        if( info.isError )
            count++;
    
    _chache[CHACHE_KEY_ERRORCOUNT] = @(count);
    
    return count;
}

#define CHACHE_KEY_TOTALUPSTR   @"totalUpRateStr"
- (NSString *)totalUploadRateString
{
    if( _chache[CHACHE_KEY_TOTALUPSTR] )
        return _chache[CHACHE_KEY_TOTALUPSTR];
    
    long long c = 0;
    
    for( TRInfo* info in _items )
        c += info.uploadRate;
    
    NSString *str = formatByteRate(c);
    _chache[CHACHE_KEY_TOTALUPSTR] = str;
    
    _totalUploadRate = c;
    
    return str;
}

- (long long)totalUploadRate
{
    return self.totalUploadRateString ? _totalUploadRate : 0;
}

#define CHACHE_KEY_TOTALDOWNSTR   @"totalDownRateStr"
- (NSString *)totalDownloadRateString
{
    if( _chache[CHACHE_KEY_TOTALDOWNSTR] )
        return _chache[CHACHE_KEY_TOTALDOWNSTR];
    
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadRate;
    
    NSString *str = formatByteRate(c);
    _chache[CHACHE_KEY_TOTALDOWNSTR] = str;
    
    _totalDownloadRate = c;
    
    return str;
}

- (long long)totalDownloadRate
{
    return self.totalDownloadRateString ? _totalDownloadRate : 0;
}

#define CHACHE_KEY_TOTALDOWNSIZESTR   @"totalDownSize"
- (NSString *)totalDownloadSizeString
{
    if( _chache[CHACHE_KEY_TOTALDOWNSIZESTR] )
        return _chache[CHACHE_KEY_TOTALDOWNSIZESTR];
    
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadedSize;
 
    NSString *str = formatByteCount(c);
    
    _chache[CHACHE_KEY_TOTALDOWNSIZESTR] = str;
    
    return str;
}

#define CHACHE_KEY_TOTALUPSIZESTR   @"totalUpSize"
- (NSString *)totalUploadSizeString
{
    if( _chache[CHACHE_KEY_TOTALUPSIZESTR] )
        return _chache[CHACHE_KEY_TOTALUPSIZESTR];
    
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.uploadedEver;
 
    NSString *str = formatByteCount(c);
    
    _chache[CHACHE_KEY_TOTALUPSIZESTR] = str;
    
    return str;
}

- (NSArray *)allTorrents
{
    return _items;
}

- (NSArray*)filterWithPredicateString:(NSString*)filterString
{
    if (_chache[filterString])
        return _chache[filterString];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
    NSArray *arr = [_items filteredArrayUsingPredicate:predicate];
    _chache[filterString] = arr;
    return arr;
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
