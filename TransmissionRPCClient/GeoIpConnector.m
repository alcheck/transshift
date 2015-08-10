//
//  GeoIpConnector.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "GeoIpConnector.h"

#define FREEGEOIP_HOST  @"http://freegeoip.net"
#define GOOGLE_HOST     @"https://maps.googleaips.com/maps/api/geocode/json"
#define GOOGLE_KEY      @"AIzaSyCif5kPXiTNQ-u259_Wumr-kT54RhS7LAk"

@implementation GeoIpConnector

{
    NSURLSession *_session;
}

- (instancetype)init
{
    self = [super init];
    
    if( !self )
        return self;
    
    _session = [NSURLSession sharedSession];
    
    return self;
}

- (void)googleReverseGeoCodingForLatitude:(double)lat Longtitude:(double)lng responseHandler:(void (^) (NSString *error, NSDictionary *dict))handler
{
    NSString *urStr = [NSString stringWithFormat:@"%@?latlng=%f,%f&key=%@", GOOGLE_HOST, lat, lng, GOOGLE_KEY];
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:urStr]];
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:r completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if( error )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler( error.description, nil);
            });
        }
        else
        {
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            if ( res.statusCode == 200 )
            {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler( nil, json );
                });
            }
            else
            {
                // signal error here
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler( @"Can not get info", nil);
                });
            }
        }
    }];
    
    [task resume];
}


- (void)getInfoForIp:(NSString *)ip responseHandler:(void (^) (NSString *error, NSDictionary *dict))handler
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/json/%@", FREEGEOIP_HOST, ip ];
    
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] ];
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:r completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if ( error )
        {
            // signal errors here
            dispatch_async(dispatch_get_main_queue(), ^{
                handler( error.description, nil);
            });
        }
        else
        {
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            if ( res.statusCode == 200 )
            {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//                NSString *cityName = json[@"city"];
//                
//                double lat = [json[@"latitude"] doubleValue];
//                double lng = [json[@"longtitude"] doubleValue];
//                
//                if( cityName.length == 0 && lat != 0 && lng != 0 )
//                {
//                    [self googleReverseGeoCodingForLatitude:lat Longtitude:lng responseHandler:^(NSString *error, NSDictionary *dict)
//                    {
//                        handler( error, dict );
//                    }];
//                }
//                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler( nil, json );
                    });
                }
            }
            else
            {
                // signal error here
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler( @"Can not get info", nil);
                });
            }
        }
    }];
    
    [task resume];
}

@end
