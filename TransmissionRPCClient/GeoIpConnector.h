//
//  GeoIpConnector.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoIpConnector : NSObject

- (void)getInfoForIp:(NSString *)ip responseHandler:(void (^) (NSString *error, NSDictionary *dict))handler;
- (void)googleReverseGeoCodingForLatitude:(double)lat Longtitude:(double)lng responseHandler:( void (^) (NSString *error, NSDictionary *dict)  )handler;

@end
