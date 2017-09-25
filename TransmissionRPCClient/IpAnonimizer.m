//
//  IpAnonimizer.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 21.04.16.
//  Copyright © 2016 Alexey Chechetkin. All rights reserved.
//

#import "IpAnonimizer.h"

/// NOBLOCK service url
static NSString * const kNoblockAnonimizerUrlString = @"http://noblockme.ru/api/anonymize?url=";

/// max request timeout
static const NSTimeInterval kRequestTimeout = 10;

@implementation IpAnonimizer

+ (void)requestAnonimUrlForUrl:(NSURL *)url usingComplitionHandler:(void (^)(NSError *, NSURL *))complitionHandler
{
    NSURLSession *session = [NSURLSession sharedSession];

    NSString *urlString = [NSString stringWithFormat:@"%@%@", kNoblockAnonimizerUrlString, url.absoluteString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:kRequestTimeout];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if( error )
        {
            dispatch_async(dispatch_get_main_queue(), ^{ complitionHandler( error, nil ); });
        }
        else
        {
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            NSString *errStatus = nil;
            NSURL    *result = nil;
            
            if ( res.statusCode == 200 )
            {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if( json[@"status"] )
                {
                    NSInteger status = [json[@"status"] integerValue];
                    if( status == 0 )
                    {
                        result = [NSURL URLWithString:json[@"result"]];
                    }
                    else
                    {
                        errStatus = [NSString stringWithFormat:@"%@", json[@"error"]];
                    }
                }
                else
                {
                        errStatus = NSLocalizedString( @"JSON response is incorrect", nil );
                }
            }
            else
            {
                errStatus = NSLocalizedString( @"HTTP status is not 200", nil );
            }
            
            NSError *error = nil;
            if( errStatus ) error = [NSError errorWithDomain:errStatus code:0 userInfo:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{ complitionHandler( error, result ); });
        }
        
    }] resume];
}

+ (NSTimeInterval)requestTimeout
{
    return kRequestTimeout;
}

+ (void)makePostRequestForUrl:(NSURL *)url withParams:(NSDictionary *)params usingComplitionHandler:(void (^)(BOOL))complitionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kRequestTimeout];
    request.HTTPMethod = @"POST";
    
    // create body
    NSMutableString *accum = [NSMutableString string];;
    
    for( NSString *key in params.allKeys )
    {
        NSString *value = params[key];
        
        [accum appendFormat:@"%@=%@&", key, value];
    }
    
    NSString *bodyString = [accum substringToIndex:accum.length - 1];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
        dispatch_async(dispatch_get_main_queue(), ^{
            complitionHandler( error ? NO:YES );
      });
    }] resume];
}

@end
