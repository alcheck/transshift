//
//  TRInfos.h
//  TransmissionRPCClient
//
//  Holds an array of trInfo and implements usfule utility methods
//  for sorting/getting

#import <Foundation/Foundation.h>
#import "TRInfo.h"

// KVC methods names for later use 
#define TRINFOS_KEY_DOWNTORRENTS    @"downloadingTorrents"
#define TRINFOS_KEY_SEEDTORRENTS    @"seedingTorrents"
#define TRINFOS_KEY_CHECKTORRENTS   @"checkingTorrents"
#define TRINFOS_KEY_STOPTORRENTS    @"stoppedTorrents"
#define TRINFOS_KEY_ACTIVETORRENTS  @"activeTorrents"
#define TRINFOS_KEY_ERRORTORRENTS   @"errorTorrents"
#define TRINFOS_KEY_ALLTORRENTS     @"allTorrents"

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

@property(nonatomic,readonly) long long totalUploadRate;
@property(nonatomic,readonly) long long totalDownloadRate;

@property(nonatomic,readonly) NSString* totalUploadRateString;
@property(nonatomic,readonly) NSString* totalDownloadRateString;
@property(nonatomic,readonly) NSString* totalDownloadSizeString;
@property(nonatomic,readonly) NSString* totalUploadSizeString;


@end
