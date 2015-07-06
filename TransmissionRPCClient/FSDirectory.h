//
//  FSDirectory.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 02.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unichar, FSItemType)
{
    FSItemTypeFolder,
    FSItemTypeFile
};

@class TRFileInfo;

@interface FSItem: NSObject

@property(nonatomic) FSItemType                     itemType;       // type of item Folde or File
@property(nonatomic, getter=isCollapsed) BOOL       collapsed;      // if folder - if folder collapsed
@property(nonatomic, readonly)BOOL                  isFolder;       // returns YES if this item is folder
@property(nonatomic, readonly)BOOL                  isFile  ;       // returns YES if this item is folder
@property(nonatomic) NSString*                      name;           // name of item (folder name or file name)
@property(nonatomic) unsigned int                   index;          // used for latter use with RPC (index in returned array from RPC request)
@property(nonatomic) NSMutableArray*                items;          // holds childrens of tupe FSItem
@property(nonatomic) TRFileInfo*                    info;           // holds TRFileInfo
@property(nonatomic) int level;                                     // holds level of item

@property(nonatomic,readonly) int                   filesCount;          // returns number of files
@property(nonatomic,readonly) int                   subfoldersCount;     // returns number of subfolders

@property(nonatomic,readonly) long long             folderSize;           // returns total size of files
@property(nonatomic,readonly) NSString*             folderSizeString;

@property(nonatomic,readonly) long long             folderDownloadedSize;    // downloaded files size
@property(nonatomic,readonly) NSString*             folderDownloadedString;

@property(nonatomic,readonly) float                 folderDownloadProgress;
@property(nonatomic,readonly) NSString*             folderDownloadProgressString;

@property(nonatomic,readonly) BOOL                  isAllFilesWanted;
@property(nonatomic,readonly) NSArray*              fileIndexes;

+ (FSItem*)itemWithName:(NSString*)name andType:(FSItemType)itemType;
- (FSItem*)addItemWithName:(NSString*)name ofType:(FSItemType)itemType;

@end


@interface FSDirectory : NSObject

@property(nonatomic,readonly) int count;    // count of elements

+ (FSDirectory*)directory;
- (FSItem*)addFilePath:(NSString*)path withIndex:(int)index;
- (void)sort;
- (FSItem*)itemAtIndex:(int)index;
- (void)setNeedToRecalcStats;

@end
