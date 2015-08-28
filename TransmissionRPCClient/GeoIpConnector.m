//
//  GeoIpConnector.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "GeoIpConnector.h"

#define FREEGEOIP_HOST  @"http://freegeoip.net/json/"
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

- (BOOL)isGrayIP:(NSString *)ip
{
    NSArray *components = [ip componentsSeparatedByString:@"."];
    if( components.count == 4 )
    {
        int firstNum = [components[0] intValue];
        int secondNum = [components[1] intValue];
        
        if( firstNum == 127 ||
            firstNum == 10 ||
           (firstNum == 192 && secondNum == 168) ||
           (firstNum == 169 && secondNum == 264) ||
           (firstNum == 172 && (secondNum >=16 && secondNum <= 32) ) )
            return YES;
    }
    
    return NO;
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
    static NSMutableDictionary *cache = nil;
    if( !cache )
        cache = [NSMutableDictionary dictionary];   
   
    // check this info in chache
    if( cache[ip] )
    {
        handler( nil, cache[ip] );
        return;
    }
    
    if( [self isGrayIP:ip] )
    {
        NSString *errDesc = NSLocalizedString(@"This ip belongs to some private net and location can not be detected", nil);
        handler( errDesc, nil );
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", FREEGEOIP_HOST, ip ];
    
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] ];
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:r completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if ( error )
        {
            NSString *errDesc = [NSString stringWithFormat: NSLocalizedString(@"Can't get info for this ip\n%@", @""), error.localizedDescription];
            
            // signal errors here
            dispatch_async(dispatch_get_main_queue(), ^{
                handler( errDesc, nil);
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
                    // store this object in cache
                    cache[ip] = json;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler( nil, json );
                    });
                }
            }
            else
            {
                // signal error here
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    NSString *errDesc = [NSString stringWithFormat:NSLocalizedString(@"Can't get info for this ip, server error: %i\n%@", @""), res.statusCode, [NSHTTPURLResponse localizedStringForStatusCode: res.statusCode] ];
                    
                    handler( errDesc, nil);
                });
            }
        }
    }];
    
    [task resume];
}

@end
