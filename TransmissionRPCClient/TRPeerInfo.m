//
//  TRPeerInfo.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRPeerInfo.h"
#import "GlobalConsts.h"

@implementation TRPeerStat

+ (TRPeerStat *)peerStatWithJSONData:(NSDictionary *)dict
{
    return [[TRPeerStat alloc] initWithJSONData:dict];
}

- (instancetype)initWithJSONData:(NSDictionary*)dict
{
    self = [super init];
    
    if( !self )
        return self;
    
    _fromChache = [NSString stringWithFormat:@"%i", [dict[TR_ARG_PEERSFROM_CHACHE] intValue] ];
    _fromDht = [NSString stringWithFormat:@"%i", [dict[TR_ARG_PEERSFROM_DHT] intValue] ];
    _fromLpd = [NSString stringWithFormat:@"%i", [dict[TR_ARG_PEERSFROM_LPD] intValue] ];
    _fromPex = [NSString stringWithFormat:@"%i", [dict[TR_ARG_PEERSFROM_PEX] intValue] ];
    _fromTracker = [NSString stringWithFormat:@"%i", [dict[TR_ARG_PEERSFROM_TRACKER] intValue] ];
    _fromIncoming = [NSString stringWithFormat:@"%i", [dict[TR_ARG_PEERSFROM_INCOMING] intValue] ];
    
    return  self;
}

@end

@implementation TRPeerInfo

+ (TRPeerInfo *)peerInfoWithJSONData:(NSDictionary *)dict
{
    return [[TRPeerInfo alloc] initWithJSONData:dict];
}

- (instancetype)initWithJSONData:(NSDictionary*)dict
{
    self = [super init];
    
    if( !self ) return self;
    
    if( dict[TR_ARG_FIELDS_PEER_ADDRESS] )
        _ipAddress = dict[TR_ARG_FIELDS_PEER_ADDRESS];
    
    if( dict[TR_ARG_FIELDS_PEER_CLIENTNAME] )
        _clientName = dict[TR_ARG_FIELDS_PEER_CLIENTNAME];
    
    if( dict[TR_ARG_FIELDS_PEER_FLAGSTR] )
        _flagString = dict[TR_ARG_FIELDS_PEER_FLAGSTR];
    
    if( dict[TR_ARG_FIELDS_PEER_PORT] )
        _port = [dict[TR_ARG_FIELDS_PEER_PORT] intValue];
    
    if( dict[TR_ARG_FIELDS_PEER_PROGRESS] )
    {
        _progress = [dict[TR_ARG_FIELDS_PEER_PROGRESS] floatValue];
        _progressString = [NSString stringWithFormat:@"%02.2f%%", _progress * 100.0f];
    }
    
    if( dict[TR_ARG_FIELDS_PEER_RATETOCLIENT] )
    {
        _rateToClient = [dict[TR_ARG_FIELDS_PEER_RATETOCLIENT] longLongValue];
        _rateToClientString = formatByteRate(_rateToClient);
    }
    
    if( dict[TR_ARG_FIELDS_PEER_RATETOPEER ])
    {
        _rateToPeer = [dict[TR_ARG_FIELDS_PEER_RATETOPEER] longLongValue];
        _rateToPeerString = formatByteRate(_rateToPeer);
    }
    
    if( dict[TR_ARG_FIELDS_PEER_ISENCRYPTED])
        _isEncrypted = [dict[TR_ARG_FIELDS_PEER_ISENCRYPTED] boolValue];

    if( dict[TR_ARG_FIELDS_PEER_ISUTP])
        _isUTP = [dict[TR_ARG_FIELDS_PEER_ISUTP] boolValue];
    
    
    return self;
}

@end
