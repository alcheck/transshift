//
//  RPCConnector.h
//  TransmissionRPCClient
//
//  Main transmission RPC connector
//

#import <Foundation/Foundation.h>
#import "RPCServerConfig.h"
#import "TRInfos.h"

@class RPCConnector;

@protocol RPCConnectorDelegate <NSObject>

@optional - (void)connector:(RPCConnector *)cn complitedRequestName:(NSString*)requestName withError:(NSString*)errorMessage;
@optional - (void)gotAllTorrents:(TRInfos *)trInfos;
@optional - (void)gotTorrentDetailedInfo:(TRInfo*)torrentInfo;

@end


@interface RPCConnector : NSObject

@property(nonatomic) NSString *lastErrorMessage;

- (instancetype)initWithConfig:(RPCServerConfig*)config andDelegate:(id<RPCConnectorDelegate>)delegate;

// make request and get all torrents
- (void)getAllTorrents;
- (void)getDetailedInfoForTorrentWithId:(int)torrentId;
- (void)stopRequests;

- (void)stopTorrent:(int)torrentId;
- (void)resumeTorrent:(int)torrentId;
- (void)verifyTorrent:(int)torrentId;
- (void)reannounceTorrent:(int)torrentId;

@end


