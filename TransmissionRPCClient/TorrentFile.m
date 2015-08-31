//
//  TorrentFile.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 31.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentFile.h"
#import "Bencoding.h"
#import "GlobalConsts.h"

#define TRSIZE_NOT_DEFINED  -1

static NSString * const kInfoKey            = @"info";
static NSString * const kNameKey            = @"name";
static NSString * const kLengthKey          = @"length";
static NSString * const kFilesKey           = @"files";
static NSString * const kFilePathKey        = @"path";
static NSString * const kAnnounceKey        = @"announce";
static NSString * const kAnnounceListKey    = @"announce-list";

static NSString * const kEmptyString        = @"";

@implementation TorrentFile

{
    NSData          *_fileData;
    NSDictionary    *_benDict;
    
    FSDirectory     *_fs;       // cached file list directory
    NSArray         *_trList;   // cached tracker list array
    
    long long       _trSize;
}

+ (instancetype)torrentFileWithURL:(NSURL *)fileURL
{
    return [[TorrentFile alloc] initWithFileURL:fileURL];
}

- (NSArray *)trackerList
{
    if( _trList )
        return _trList;
    
    NSMutableArray  *list = nil;
    
    if( _benDict[kAnnounceListKey] )
    {
        list = [NSMutableArray array];
        for( NSArray *arr in _benDict[kAnnounceListKey] )
        {
            NSURL *url = [NSURL URLWithString:arr[0]];
            if (url)
                [list addObject:url.host];
        }
    }
    else if( _benDict[kAnnounceKey] )
    {
        list = [NSMutableArray array];
        NSURL *url = [NSURL URLWithString:_benDict[kAnnounceKey]];
        [list addObject:url.host];
    }
    
    _trList = list.count > 0 ? list : nil;
    
    return _trList;
}

- (NSString *)name
{
    return _benDict[kInfoKey][kNameKey];
}

- (long long)torrentSize
{
    if( _trSize != TRSIZE_NOT_DEFINED )
        return _trSize;
    
    if( _benDict[kInfoKey][kLengthKey] )
    {
        _trSize = [_benDict[kInfoKey][kLengthKey] longLongValue];
        return _trSize;
    }
    else
    {
        _trSize = 0;
        NSArray *fileDescs = _benDict[kInfoKey][kFilesKey];
        
        if( fileDescs )
        {
            for( NSDictionary *fileDesc in fileDescs )
                _trSize += [fileDesc[kLengthKey] longLongValue];
        }
        
        return _trSize;
    }
}

- (NSString *)torrentSizeString
{
    return formatByteCount(self.torrentSize);
}

- (FSDirectory *)fileList
{
    if( _fs )
        return _fs;
    
     NSArray *fileDescs = _benDict[kInfoKey][kFilesKey];
    
    if( fileDescs && fileDescs.count > 0 )
    {
        _fs = [FSDirectory directory];
        int idx = 0;
        
        for( NSDictionary *fileDesc in fileDescs )
        {
            FSItem *item = [_fs addPathComonents:fileDesc[kFilePathKey] andRpcIndex:idx];
            item.length = [fileDesc[kLengthKey] longLongValue];
            item.lengthString = formatByteCount( item.length );
            item.wanted = YES;
            item.downloadProgress = 0.001;
            item.downloadProgressString = kEmptyString;
            idx++;
        }
        
        [_fs sort];
     }
    
    return _fs;
}

- (NSData *)torrentData
{
    return _fileData;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    
    if( self )
    {
        _fileData = [NSData dataWithContentsOfURL:fileURL];
        
        if( _fileData )
        {
            _benDict = decodeObjectFromBencodedData( _fileData );
            
            if( _benDict )
            {
                _trSize = TRSIZE_NOT_DEFINED;
                
                return self;
            }
        }
    }
    
    return nil;
}

@end
