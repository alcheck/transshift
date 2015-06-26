//
//  RPCConnector.h
//  TransmissionRPCClient
//
//  Main transmission RPC connector
//

#import <Foundation/Foundation.h>
#import "RPCServerConfig.h"

// torrent statuses
#define TR_STATUS_STOPPED         0 /* Torrent is stopped */
#define TR_STATUS_CHECK_WAIT      1 /* Queued to check files */
#define TR_STATUS_CHECK           2 /* Checking files */
#define TR_STATUS_DOWNLOAD_WAIT   3 /* Queued to download */
#define TR_STATUS_DOWNLOAD        4 /* Downloading */
#define TR_STATUS_SEED_WAIT       5 /* Queued to seed */
#define TR_STATUS_SEED            6 /* Seeding */

// RPC command methods names
#define RPC_COMMAND_GETALLTORRENTS  @"get-all-torrents"

@class RPCConnector;

@protocol RPCConnectorDelegate <NSObject>

@optional - (void)connector:(RPCConnector*)cn complitedRequestName:(NSString*)requestName withError:(NSString*)errorMessage;
@optional - (void)gotAllTorrents:(NSArray*)arrayOfJsonTorrents;

@end


@interface RPCConnector : NSObject

@property(nonatomic) NSString *lastErrorMessage;

- (instancetype)initWithConfig:(RPCServerConfig*)config andDelegate:(id<RPCConnectorDelegate>)delegate;

// make request and get all torrents
- (void)getAllTorrents;
- (void)stopRequests;

@end


