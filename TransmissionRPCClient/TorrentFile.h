//
//  TorrentFile.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 31.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDirectory.h"

@interface TorrentFile : NSObject

/// init and return new instance of TorrentFile
/// or nil if file can not be parsed or readed
+ (instancetype)torrentFileWithURL:(NSURL *)fileURL;

@property( nonatomic, readonly ) NSString       *name;
@property( nonatomic, readonly ) NSArray        *trackerList;
@property( nonatomic, readonly ) FSDirectory    *fileList;
@property( nonatomic, readonly ) long long      torrentSize;
@property( nonatomic, readonly ) NSString       *torrentSizeString;
@property( nonatomic, readonly ) NSData         *torrentData;

@end
