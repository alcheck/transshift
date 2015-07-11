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
@property(nonatomic,readonly) NSArray* activeTorrents;
@property(nonatomic,readonly) NSArray* errorTorrents;

@property(nonatomic,readonly) int downloadCount;
@property(nonatomic,readonly) int seedCount;
@property(nonatomic,readonly) int allCount;
@property(nonatomic,readonly) int stopCount;
@property(nonatomic,readonly) int checkCount;
@property(nonatomic,readonly) int activeCount;
@property(nonatomic,readonly) int errorCount;

@property(nonatomic,readonly) NSString* totalUploadRateString;
@property(nonatomic,readonly) NSString* totalDownloadRateString;
@property(nonatomic,readonly) NSString* totalDownloadSizeString;
@property(nonatomic,readonly) NSString* totalUploadSizeString;


@end
