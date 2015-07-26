//
//  TrackerStat.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 23.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackerStat : NSObject

+ (instancetype)initFromJSON:(NSDictionary*)json;

@property(nonatomic,readonly) int       trackerId;

@property(nonatomic,readonly) NSString *host;
@property(nonatomic,readonly) NSString *scrape;

@property(nonatomic,readonly) int       seederCount;
@property(nonatomic,readonly) int       leecherCount;
@property(nonatomic,readonly) int       downloadCount;
@property(nonatomic,readonly) int       lastAnnouncePeerCount;

@property(nonatomic,readonly) NSString *lastAnnounceResult;
@property(nonatomic,readonly) NSString *lastScrapeResult;

@property(nonatomic,readonly) NSString *lastAnnounceTimeString;
@property(nonatomic,readonly) NSString *lastScrapeTimeString;

@property(nonatomic,readonly) NSString *nextAnnounceTimeString;
@property(nonatomic,readonly) NSString *nextScrapeTimeString;

@property(nonatomic,readonly) BOOL      lastAnnounceSucceeded;
@property(nonatomic,readonly) BOOL      lastScrapeSucceeded;

@property(nonatomic,readonly) BOOL      hasAnnounced;
@property(nonatomic,readonly) BOOL      hasScraped;

@property(nonatomic,readonly) int       scrapeState;
@property(nonatomic,readonly) int       announceState;

@end
