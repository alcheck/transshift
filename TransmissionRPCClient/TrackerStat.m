
//
//  TrackerStat.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TrackerStat.h"
#import "RPCConfigValues.h"
#import "GlobalConsts.h"

@interface TrackerStat()
@end

@implementation TrackerStat

+ (instancetype)initFromJSON:(NSDictionary *)json
{
    return [[TrackerStat alloc] initFromJSON:json];
}

- (instancetype)initFromJSON:(NSDictionary*)dict
{
    self = [super init];
    
    if( !self )
        return self;
    
    _trackerId = [dict[TR_ARG_TRACKER_ID] intValue];
    
    if( dict[TR_ARG_TRACKER_HOST] )
        _host = dict[TR_ARG_TRACKER_HOST];
    
    if( dict[TR_ARG_TRACKER_SCRAPE] )
        _scrape = dict[TR_ARG_TRACKER_SCRAPE];
    
    if( dict[TR_ARG_TRACKER_SEEDERCOUNT] )
    {
        _seederCount = [dict[TR_ARG_TRACKER_SEEDERCOUNT] intValue];
        if( _seederCount < 0 )
            _seederCount = 0;
    }
    
    if( dict[TR_ARG_TRACKER_LEECHERCOUNT] )
    {
        _leecherCount = [dict[TR_ARG_TRACKER_LEECHERCOUNT] intValue];
        if( _leecherCount < 0 )
            _leecherCount = 0;
    }
    
    if( dict[TR_ARG_TRACKER_DOWNLOADCOUNT] )
    {
        _downloadCount = [dict[TR_ARG_TRACKER_DOWNLOADCOUNT] intValue];
        if( _downloadCount < 0 )
            _downloadCount = 0;
    }
    
    if( dict[TR_ARG_TRACKER_LASTANNOUNCEPEERCOUNT] )
    {
        _lastAnnouncePeerCount = [dict[TR_ARG_TRACKER_LASTANNOUNCEPEERCOUNT] intValue];
        if( _lastAnnouncePeerCount < 0 )
            _lastAnnouncePeerCount = 0;
    }
    
    if( dict[TR_ARG_TRACKER_LASTANNOUNCERESULT] )
        _lastAnnounceResult = dict[TR_ARG_TRACKER_LASTANNOUNCERESULT];
    
    if( dict[TR_ARG_TRACKER_LASTSCRAPERESULT] )
        _lastScrapeResult = dict[TR_ARG_TRACKER_LASTSCRAPERESULT];
    
    if( dict[TR_ARG_TRACKER_LASTANNOUNCETIME] )
        _lastAnnounceTimeString = formatDateFrom1970Short([dict[TR_ARG_TRACKER_LASTANNOUNCETIME] doubleValue]);
    
    if( dict[TR_ARG_TRACKER_LASTSCRAPETIME] )
        _lastScrapeTimeString = formatDateFrom1970Short([dict[TR_ARG_TRACKER_LASTSCRAPETIME] doubleValue]);
    
    if( dict[TR_ARG_TRACKER_NEXTANNOUNCETIME] )
        _nextAnnounceTimeString = formatDateFrom1970Short([dict[TR_ARG_TRACKER_NEXTANNOUNCETIME] doubleValue]);
    
    if( dict[TR_ARG_TRACKER_NEXTSCRAPETIME] )
        _nextScrapeTimeString = formatDateFrom1970Short([dict[TR_ARG_TRACKER_NEXTSCRAPETIME] doubleValue]);
    
    if( dict[TR_ARG_TRACKER_LASTANNOUNCESUCCEEDED] )
        _lastAnnounceSucceeded = [dict[TR_ARG_TRACKER_LASTANNOUNCESUCCEEDED] boolValue];
    
    if( dict[TR_ARG_TRACKER_LASTSCRAPESUCCEEDED] )
        _lastScrapeSucceeded = [dict[TR_ARG_TRACKER_LASTSCRAPESUCCEEDED] boolValue];
    
    if( dict[TR_ARG_TRACKER_HASANNOUNCED] )
        _hasAnnounced = [dict[TR_ARG_TRACKER_HASANNOUNCED] boolValue];
    
    if( dict[TR_ARG_TRACKER_HASSCRAPED] )
        _hasScraped = [dict[TR_ARG_TRACKER_HASSCRAPED] boolValue];
    
    if( dict[TR_ARG_TRACKER_ANNOUNCESTATE] )
        _announceState = [dict[TR_ARG_TRACKER_ANNOUNCESTATE] intValue];
    
    if( dict[TR_ARG_TRACKER_SCRAPESTATE] )
        _scrapeState = [dict[TR_ARG_TRACKER_SCRAPESTATE] intValue];
    
    return self;
}

@end
