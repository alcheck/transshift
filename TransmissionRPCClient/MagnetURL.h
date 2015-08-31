//
//  MagnetURL.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 31.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MagnetURL : NSObject

/// init magnet url with url
+ (instancetype)magnetWithURL:(NSURL *)url;

/// check if this url scheme is magnet
+ (BOOL)isMagnetURL:(NSURL *)url;

/// full url string
@property( nonatomic, readonly ) NSString   *urlString;

/// returns torrent name (if avalable) or hash string
@property( nonatomic, readonly ) NSString   *name;

/// returns torrent size if avalable of @"unknown size"
@property( nonatomic, readonly ) NSString   *torrentSizeString;

/// returns tracker list if avalable or nil
@property( nonatomic, readonly ) NSArray    *trackerList;

@end
