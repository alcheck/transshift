//
//  IpAnonimizer.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 21.04.16.
//  Copyright © 2016 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IpAnonimizer : NSObject

/// requests anonymous url for given url and call complitionHandler upon end of the request
+ (void) requestAnonimUrlForUrl:(NSURL *)url usingComplitionHandler:(void (^)(NSError *err, NSURL *url))complitionHandler;

/// returns default request timeout
+ (NSTimeInterval)requestTimeout;

/// make post request for url with post params "name" -> "value"
+ (void) makePostRequestForUrl:(NSURL *)url withParams:(NSDictionary *)params usingComplitionHandler:(void (^)(BOOL success))complitionHandler;

@end
