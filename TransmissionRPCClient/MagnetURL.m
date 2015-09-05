//
//  MagnetURL.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 31.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "MagnetURL.h"
#import "GlobalConsts.h"

#define TRSIZE_NOT_DEFINED -1

static NSString * const kMagnetUrlSchemeName                            = @"magnet";
static NSString * const kMagnetParamsSeparator                          = @"&";
static NSString * const kMagnetContentSeparator                         = @"?";
static NSString * const kMagnetParamPrefixTorrentSize                   = @"xl=";
static NSString * const kMagnetParamPrefixTorrentSizeString             = @"dl=";
static NSString * const kMagnetParamPrefixTorrentName                   = @"dn=";
static NSString * const kMagnetParamPrefixTorrentTracker                = @"tr=";
static NSString * const kMagnetParamPrefixTorrentHashUrn                = @"xt=";
static NSString * const kMagnetParamPrefixTorrentHashParamSeparator     = @":";
static NSString * const kMagnetComponentSeparator                       = @"=";

@implementation MagnetURL

{
    NSString        *_str;
    NSString        *_name;
    NSString        *_hash;
    
    NSMutableArray  *_trackers;
    
    long long       _size;
}

+ (instancetype)magnetWithURL:(NSURL *)url
{
    return [[MagnetURL alloc] initWithURL:url];
}

+ (BOOL)isMagnetURL:(NSURL *)url
{
    return [url.scheme isEqualToString:kMagnetUrlSchemeName];
}

- (NSString *)urlString
{
    return _str;
}

- (long long)getLongFromComponent:(NSString *)component
{
    NSArray *comps = [component componentsSeparatedByString:@"="];
    if( comps.count == 2 )
    {
        return [comps[1] longLongValue];
    }
    
    return 0;
}

- (NSString *)getStringFromComponent:(NSString *)component
{
    NSArray *comps = [component componentsSeparatedByString:kMagnetComponentSeparator];
    
    if( comps.count == 2 )
    {
        return [comps[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSString *)getUrlEncodedStringFromComponent:(NSString *)component
{
    NSString *s = [self getStringFromComponent:component];
    
    if( s )
    {
        s = [s stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        return [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

// parse magnet
- (void)parseMagnetString
{
    _size = TRSIZE_NOT_DEFINED;
    
    NSArray *comps = [_str componentsSeparatedByString:kMagnetContentSeparator];
    
    if( comps.count > 0 )
    {
        NSString * s = [comps lastObject];
        
        comps = [s componentsSeparatedByString:kMagnetParamsSeparator];

        _trackers = nil;
        
        if( comps.count > 0 )
        {
            for( NSString *s in comps )
                [self parseString:s];
        }
        else
        {
            [self parseString:s];
        }
    }
 }

- (void)parseString:(NSString *)s
{
    if( [s hasPrefix:kMagnetParamPrefixTorrentSize] )
    {
        _size = [self getLongFromComponent:s];
    }
    else if( [s hasPrefix:kMagnetParamPrefixTorrentSizeString] )
    {
        _size = [[self getStringFromComponent:s] longLongValue];
    }
    else if( [s hasPrefix:kMagnetParamPrefixTorrentHashUrn] )
    {
        NSString *stmp = [self getStringFromComponent:s];
        NSArray *ctmp = [stmp componentsSeparatedByString:kMagnetParamPrefixTorrentHashParamSeparator];
        _hash = [ctmp lastObject];
    }
    else if( [s hasPrefix:kMagnetParamPrefixTorrentName] )
    {
        _name = [self getUrlEncodedStringFromComponent:s];
    }
    else if( [s hasPrefix:kMagnetParamPrefixTorrentTracker] )
    {
        if( _trackers == nil )
            _trackers = [NSMutableArray array];
        
        [_trackers addObject:[self getStringFromComponent:s] ];
    }
 }

- (NSString *)name
{
    NSString *sn = NSLocalizedString(@"MagnetTorrentNameUnknown", nil);
    
    if( _name )
        sn = _name;
    else if( _hash )
    {
        sn = [NSString stringWithFormat:NSLocalizedString(@"MagnetTorrentNameHash", nil), _hash];
    }
    
    return sn;
}

- (NSString *)torrentSizeString
{
    NSString *sz = NSLocalizedString( @"MagnetTorrentSizeUnknown", nil );
    
    if( _size != TRSIZE_NOT_DEFINED )
    {
        sz = formatByteCount(_size);
    }
    
    return sz;
}

- (NSArray *)trackerList
{
    return _trackers;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if( self )
    {
        _str = url.description;
        [self parseMagnetString];
    }
    
    return self;
}

@end
