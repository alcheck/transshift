//
//  TRInfos.h
//  TransmissionRPCClient
//
//  Holds an array of trInfo and implements usfule utility methods
//  for sorting/getting

#import <Foundation/Foundation.h>
#import "TRInfo.h"

@interface TRInfos : NSObject

+ (TRInfos*) infosFromArrayOfJSON:(NSArray*)jsonArray;

@property(nonatomic,readonly) NSArray* downloadingTorrents;
@property(nonatomic,readonly) NSArray* seedingTorrents;
@property(nonatomic,readonly) NSArray* checkingTorrents;
@property(nonatomic,readonly) NSArray* allTorrents;
@property(nonatomic,readonly) NSArray* stoppedTorrents;

@property(nonatomic,readonly) NSUInteger downloadCount;
@property(nonatomic,readonly) NSUInteger seedCount;
@property(nonatomic,readonly) NSUInteger allCount;
@property(nonatomic,readonly) NSUInteger stopCount;
@property(nonatomic,readonly) NSUInteger checkCount;

@end
