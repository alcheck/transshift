//
//  FSDirectory.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 02.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FSITEM_INDEXNOTFOUND    -1

//@class TRFileInfo;

@interface FSItem: NSObject

/// Returns YES if this is a folder
@property(nonatomic) BOOL                           isFolder;
/// Returns YES if folder is collapsed
@property(nonatomic, getter=isCollapsed) BOOL       collapsed;
/// Returns YES if this is a file
@property(nonatomic, readonly)BOOL                  isFile;
/// File path with
@property(nonatomic) NSString                       *fullName;
/// File name or folder name (w/o starting paths)
@property(nonatomic) NSString                       *name;
/// Bytes downloaded
@property(nonatomic) long long                      bytesComplited;
/// Bytes downloaded - string representation
@property(nonatomic) NSString                       *bytesComplitedString;
/// Total length of file/folder
@property(nonatomic) long long                      length;
/// Total length of file/folder - string representation
@property(nonatomic) NSString                       *lengthString;
/// Returns YES if this file/folder Wanted
@property(nonatomic) BOOL                           wanted;
/// Priority of this file/folder
@property(nonatomic) int                            priority;
/// Download progress for file/folder (0 ... 1)
@property(nonatomic) float                          downloadProgress;
/// Download progress - string representation (0 .. 100%)
@property(nonatomic) NSString                       *downloadProgressString;
/// File index in RPC results (valid only for files)
@property(nonatomic) int                            rpcIndex;
/// Holds subfolders/files - if this is a Folder
@property(nonatomic) NSMutableArray                 *items;
/// Holds level of this file/folder
@property(nonatomic) int                            level;
/// Get count of files in this folder
@property(nonatomic,readonly) int                   filesCount;
/// Get count of subfolders in this folder
@property(nonatomic,readonly) int                   subfoldersCount;
/// Returns RPC file indexes
@property(nonatomic,readonly) NSArray               *rpcFileIndexes;
/// Returns RPC wanted file indexes
@property(nonatomic,readonly) NSArray               *rpcFileIndexesWanted;
/// Returns RPC unwanted file indexes
@property(nonatomic,readonly) NSArray               *rpcFileIndexesUnwanted;
/// Holds parent reference
@property(nonatomic,weak) FSItem                    *parent;

@property(nonatomic) BOOL                           waitingForWantedUpdate;
@property(nonatomic) BOOL                           waitingForPriorityUpdate;
@property(nonatomic) NSInteger                      rowIndex;

/// Create new item with name, it could be folder, or file
+ (FSItem *)itemWithName:(NSString*)name isFolder:(BOOL)isFolder;
/// Add new item to folder item
- (FSItem *)addItemWithName:(NSString*)name isFolder:(BOOL)isFolder;

@end


@interface FSDirectory : NSObject

/// Create empty directory
+ (FSDirectory *)directory;

/// Get count of items in directory
@property(nonatomic,readonly) NSInteger     count;    // count of elements

/// Get root FSItem
@property(nonatomic,readonly) FSItem        *rootItem;

/// add new item to directory with file path
- (FSItem *)addFilePath:(NSString*)path andRpcIndex:(int)rpcIndex;

/// add new item to directory with separated file path
- (FSItem *)addPathComonents:(NSArray *)pathComponents andRpcIndex:(int)rpcIndex;

/// add new item to directory with file/filsetats infos from JSON rpc answer
- (FSItem *)addItemWithJSONFileInfo:(NSDictionary *)fileInfo JSONFileStatInfo:(NSDictionary *)fileStatInfo rpcIndex:(int)rpcIndex;

/// Sort all elements in directory
- (void)sort;

/// Get directory item at given row index
/// skip collapsed folder items
- (FSItem *)itemAtIndex:(NSInteger)index;

/// Get row index for searching item
- (NSInteger)indexForItem:(FSItem *)item;

/// Set recalculation statistics flag
- (void)setNeedToRecalcStats;

/// Recalculate index table
- (void)recalcRowIndexes;

- (NSArray *)childIndexesForItem:(FSItem *)item startRow:(NSInteger)startRow section:(NSInteger)section;

@end
