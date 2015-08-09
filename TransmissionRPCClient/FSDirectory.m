//
//  FSDirectory.m
//  TransmissionRPCClient
//
//  File System Directory data class
//  holds file/directory tree
//  using for representation on UITableView

#import "FSDirectory.h"
#import "TRFileInfo.h"

#define PATH_SPLITTER_STRING        @"/"

@interface FSItem()

- (void)setNeedToRecalcStats;

@end

@implementation FSItem

{
    int _filesCount;
    long long _filesSize;
    long long _filesDownloadedSize;
    
    BOOL _allFilesWanted;               // flag indicates that all files withing this folder is wanted
    
    BOOL _needToCalcStats;
}

+ (FSItem *)itemWithName:(NSString *)name andType:(FSItemType)itemType
{
    FSItem *item = [[FSItem alloc] init];
    
    item.itemType = itemType;
    item.name = name;
    
    return item;
}

- (instancetype)init
{
    self = [super init];
    
    if( !self )
        return self;
    
    _level = 0;
    _needToCalcStats = YES;
    
    return self;
}

- (void)setInfo:(TRFileInfo *)info
{
    _info = info;
    _needToCalcStats = YES;
}

- (NSString *)folderSizeString
{
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.allowsNonnumericFormatting = NO;
    return [formatter stringFromByteCount:self.folderSize];
}

- (NSString *)folderDownloadedString
{
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.allowsNonnumericFormatting = NO;
    return [formatter stringFromByteCount:self.folderDownloadedSize];
}

- (float)folderDownloadProgress
{
    [self calcStats];
    
    if( _filesSize == 0 )
        @throw [NSException exceptionWithName:@"FSItem" reason:@"folderDownloadProgress: _fileSize == 0, devide by ZERO" userInfo:nil];
    
    return (float)((double)_filesDownloadedSize/(double)_filesSize);
}

- (NSString *)folderDownloadProgressString
{
    return [NSString stringWithFormat:@"%03.2f%%",  self.folderDownloadProgress * 100.0f ];
}

- (int)filesCount
{
    [self calcStats];
    return _filesCount;
}

- (long long)folderSize
{
    [self calcStats];
    return _filesSize;
}

- (long long)folderDownloadedSize
{
    [self calcStats];
    return _filesDownloadedSize;
}

- (void)calcStats
{
    if( _needToCalcStats )
    {
        _filesCount = 0;
        _filesSize = 0;
        _filesDownloadedSize = 0;
        _subfoldersCount = 0;
        _allFilesWanted = YES;
        _needToCalcStats = NO;
        
        [self traverseAndCount:self];
    }
}

- (void)setNeedToRecalcStats
{
    _needToCalcStats = YES;
    
    if( _items )
        for( FSItem *i in _items )
            [i setNeedToRecalcStats];
}

- (void)traverseAndCount:(FSItem*)item
{
    if( item.items )
    {
        for( FSItem *i in item.items )
        {
            if( i.isFile )
            {
                _filesCount++;
                
                if( i.info )
                {
                    _filesSize += i.info.length;
                    _filesDownloadedSize += i.info.bytesComplited;
                    
                    if( !i.info.wanted )
                        _allFilesWanted = NO;
                }
            }
            else
            {
                _subfoldersCount++;
                [self traverseAndCount:i];
            }
        }
    }
}

- (void)setIsAllFilesWanted:(BOOL)isAllFilesWanted
{
    [self setNeedToRecalcStats];
    [self traverse:self setWanted:isAllFilesWanted];
}

- (void)traverse:(FSItem*)item setWanted:(BOOL)wanted
{
    if( item.items )
    {
        for( FSItem *i in item.items )
        {
            if( i.isFile )
            {
                if( i.info )
                {
                    i.info.wanted = wanted;
                }
            }
            else
            {
                [self traverse:i setWanted:wanted];
            }
        }
    }
}

- (NSArray*)fileIndexesUnwanted
{
    NSMutableArray *indexes = [NSMutableArray array];
    
    if (_items)
    {
        for( FSItem *i in _items )
        {
            if( i.isFile && !i.info.wanted )
            {
                [indexes addObject:@(i.index)];
            }
            else
            {
                [indexes addObjectsFromArray:i.fileIndexesUnwanted];
            }
        }
    }
    
    return indexes;
}


- (NSArray*)fileIndexesWanted
{
    NSMutableArray *indexes = [NSMutableArray array];
    
    if (_items)
    {
        for( FSItem *i in _items )
        {
            if( i.isFile && i.info.wanted )
            {
                [indexes addObject:@(i.index)];
            }
            else
            {
                [indexes addObjectsFromArray:i.fileIndexesWanted];
            }
        }
    }
    
    return indexes;
}

- (NSArray *)fileIndexes
{
    NSMutableArray *indexes = [NSMutableArray array];
    
    if (_items)
    {
        for( FSItem *i in _items )
        {
            if( i.isFile )
            {
                [indexes addObject:@(i.index)];
            }
            else
            {
                [indexes addObjectsFromArray:i.fileIndexes];
            }
        }
    }
    
    return indexes;
}

- (BOOL)isFolder
{
    return _itemType == FSItemTypeFolder;
}

- (BOOL)isFile
{
    return _itemType == FSItemTypeFile;
}

- (BOOL)isAllFilesWanted
{
    [self calcStats];
    return _allFilesWanted;
}


// add item to children, if it is already exists
// return existing item

- (FSItem *)addItemWithName:(NSString *)name ofType:(FSItemType)itemType
{
    // lazy instanciating
    if( !_items )
        _items = [NSMutableArray array];
    
    FSItem *resItem = nil;

    // finding item
    for( FSItem* item in _items )
    {
        if (item.itemType == itemType && [item.name isEqualToString:name])
        {
            resItem = item;
            break;
        }
    }
    
    // item not found add it to the children
    if( !resItem )
    {
        resItem = [FSItem itemWithName:name andType:itemType];
        resItem.level = _level + 1;
        [_items addObject:resItem];
        _needToCalcStats = YES;
    }
    
    return resItem;
}

- (NSString *)description
{
    NSMutableString *spaces = [NSMutableString string];
    for (int i = 0; i < _level; i++)
        [spaces appendString:@"  "];
    
    if( _itemType == FSItemTypeFile )
        return [NSString stringWithFormat:@"%@%@!\n",spaces, _name];
    
    NSMutableString *s = [NSMutableString stringWithFormat:@"%@/%@\n",spaces, _name];
    
    if( !_collapsed )
        for( FSItem* item in _items )
            [s appendString: item.description];
    
    return s;
}

- (void)sort
{
    if( _items )
    {
        [_items sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             FSItem *item1 = (FSItem*)obj1;
             FSItem *item2 = (FSItem*)obj2;
             
             // if bouth item are folder return comparison result
             if( item1.itemType == FSItemTypeFolder && item2.itemType == FSItemTypeFolder )
                 return [item1.name compare:item2.name];
             
             // folders first
             if ( item1.itemType == FSItemTypeFolder && item2.itemType == FSItemTypeFile )
                 return NSOrderedAscending;
             
             if( item1.itemType == FSItemTypeFile && item2.itemType == FSItemTypeFolder )
                 return NSOrderedDescending;
             
             // both items if files
             return [item1.name compare:item2.name];
         }];
        
        for( FSItem *item in _items )
            [item sort];
    }
}

@end

@implementation FSDirectory

{
    FSItem* _root;
    int     _curIndex;
    int     _findIndex;
    FSItem* _foundItemAtIndex;
}

+ (FSDirectory *)directory
{
    return [[FSDirectory alloc] init];
}

- (instancetype)init
{
    self = [super init];
    
    if( self )
    {
        _root = [FSItem itemWithName:@"" andType:FSItemTypeFolder];      // init root element (always folder)
    }
    
    return self;
}

- (FSItem *)rootItem
{
    return _root;
}

// add file to tree
// file is a path with format /root/subfolder/.../filename it
// should be from root
- (FSItem*)addFilePath:(NSString*)path withIndex:(int)index
{
    // trim path
    path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:PATH_SPLITTER_STRING]];
    
    // split the path string
    NSArray *arr = [path componentsSeparatedByString:PATH_SPLITTER_STRING];
    
    if( !arr )
        @throw [NSException exceptionWithName:@"FSDirectory - addFilePath"
                                       reason:@"can not split filePath - nil array retrieved"
                                     userInfo:nil];
    
    // add all components to the tree (from root)
    FSItem* levelItem = _root;
    
    for( int level = 0; level < arr.count; level++ )
    {        
        NSString *itemName = arr[level];
        
        // last item in array is file, the others - folders
        FSItemType itemType = (level == (arr.count -1) ? FSItemTypeFile : FSItemTypeFolder);
        
        levelItem = [levelItem addItemWithName:itemName ofType:itemType];
        
        if( itemType == FSItemTypeFile )
            levelItem.index = index;
    }
    
    return levelItem;
}

- (FSItem*)itemAtIndex:(int)index
{
    _curIndex = -1;
    _findIndex = index;
    _foundItemAtIndex = nil;
    
    [self stepAndInrementFromItem:_root];
    
    return _foundItemAtIndex;
}

- (void)stepAndInrementFromItem:(FSItem*)item
{
    if( _foundItemAtIndex )
        return;
    
    for( FSItem *i in item.items )
    {
        if( ++_curIndex == _findIndex )
        {
            _foundItemAtIndex = i;
            return;
        }
        
        if( i.items && !i.collapsed )
            [self stepAndInrementFromItem:i];
    }
}

- (int)count
{
    _curIndex = 0;
    _findIndex = -1;
    _foundItemAtIndex = nil;
    
    [self stepAndInrementFromItem:_root];
    return _curIndex;
}


- (int)indexForItem:(FSItem*)item
{
    _curIndex = -1;
    [self stepAndFindItem:item startFrom:_root];
    return _curIndex;
}

- (void)stepAndFindItem:(FSItem *)item startFrom:(FSItem *)rootItem
{
    for( FSItem *i in rootItem.items )
    {
        _curIndex++;
        
        if( i == item )
            return;
        
        if( !i.isCollapsed && i.items.count > 0 )
            [self stepAndFindItem:item startFrom:i];
    }
}

- (void)stepAndStoreIndexesForSubItemsOfItem:(FSItem *)item storeTo:(NSMutableArray *)indexes
{
    for( FSItem *i in item.items )
    {
        [indexes addObject:@(++_curIndex)];
        if( !i.isCollapsed && i.items.count > 0 )
            [self stepAndStoreIndexesForSubItemsOfItem:i storeTo:indexes];
    }
}

/// Get this item children indexes
- (NSArray *)childIndexesForItem:(FSItem *)item
{
    int idx = [self indexForItem:item];
    if( idx >= 0 )
    {
        NSMutableArray *indexes = [NSMutableArray array];
        _curIndex = idx;
        [self stepAndStoreIndexesForSubItemsOfItem:item storeTo:indexes];
        return indexes;
    }
    
    return nil;
}


- (NSString *)description
{
    return _root.description;
}

- (void)sort
{
    [_root sort];
}

- (void)setNeedToRecalcStats
{
    [_root setNeedToRecalcStats];
}

@end
