//
//  RPCConnector.h
//  TransmissionRPCClient
//
//  Main transmission RPC connector
//

#import <Foundation/Foundation.h>
#import "RPCServerConfig.h"
#import "TRInfos.h"
#import "TRPeerInfo.h"
#import "TRFileInfo.h"

@class RPCConnector;

@protocol RPCConnectorDelegate <NSObject>

@optional - (void)connector:(RPCConnector *)cn complitedRequestName:(NSString*)requestName withError:(NSString*)errorMessage;
@optional - (void)gotAllTorrents:(TRInfos *)trInfos;
@optional - (void)gotTorrentDetailedInfo:(TRInfo*)torrentInfo;
@optional - (void)gotTorrentStopedWithId:(int)torrentId;
@optional - (void)gotTorrentResumedWithId:(int)torrentId;
@optional - (void)gotTorrentDeletedWithId:(int)torrentId;
@optional - (void)gotTorrentVerifyedWithId:(int)torrentId;
@optional - (void)gotTorrentReannouncedWithId:(int)torrentId;
@optional - (void)gotTorrentAdded;
@optional - (void)gotAllPeers:(NSArray*)peerInfos forTorrentWithId:(int)torrentId;
@optional - (void)gotAllFiles:(NSArray*)fileInfos forTorrentWithId:(int)torrentId;

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
- (void)deleteTorrentWithId:(int)torrentId deleteWithData:(BOOL)deleteWithData;

- (void)addTorrentWithData:(NSData*)data;

- (void)getAllPeersForTorrentWithId:(int)torrentId;
- (void)getAllFilesForTorrentWithId:(int)torrentId;

@end


