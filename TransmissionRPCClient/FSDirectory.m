//
//  FSDirectory.m
//  TransmissionRPCClient
//
//  File System Directory data class
//  holds file/directory tree
//  using for representation on UITableView

#import "FSDirectory.h"
#import "RPCConfigValues.h"
#import "TRFileInfo.h"
#import "GlobalConsts.h"

#define PATH_SPLITTER_STRING        @"/"

@interface FSItem()

- (void)setNeedToRecalcStats;

@end

@implementation FSItem

{
    int         _filesCount;
    long long   _filesLength;
    long long   _filesBytesComplited;
    BOOL        _allFilesWanted;               // flag indicates that all files withing this folder is wanted
    BOOL        _needToCalcStats;
    BOOL        _wanted;
    long long   _length;
    long long   _bytesComplited;
}

+ (FSItem *)itemWithName:(NSString *)name isFolder:(BOOL)isFolder
{
    FSItem *item = [[FSItem alloc] initWithName:name isFolder:isFolder];
    return item;
}

- (instancetype)initWithName:(NSString *)name isFolder:(BOOL)isFolder
{
    self = [super init];
    
    if( !self )
        return self;
    
    _level = 0;
    _needToCalcStats = YES;
    _name = name;
    _isFolder = isFolder;
    
    if( isFolder )
        _items = [NSMutableArray array];
    
    return self;
}

- (int)filesCount
{
    if( !_isFolder )
        return 0;
    
    [self calcStats];
    return _filesCount;
}

- (long long)length
{
    if( !_isFolder )
        return _length;
    
    [self calcStats];
    return _filesLength;
}

- (void)setLength:(long long)length
{
    _length = length;
    _lengthString = formatByteCount(length);
}

- (NSString *)lengthString
{
    if( !_isFolder )
        return _lengthString;

    return formatByteCount(self.length);
}

- (long long)bytesComplited
{
    if( !_isFolder )
        return _bytesComplited;
    
    [self calcStats];
    return _filesBytesComplited;
}

- (void)setBytesComplited:(long long)bytesComplited
{
    _bytesComplited = bytesComplited;
    _bytesComplitedString = formatByteCount(bytesComplited);
    
    _downloadProgress = 0.0f;
    if( _length > 0 )
        _downloadProgress = (float)( (double)_bytesComplited/(double)_length );
    
    _downloadProgressString = [NSString stringWithFormat:@"%0.2f%%", _downloadProgress * 100.0f];
}

- (NSString *)bytesComplitedString
{
    if( !_isFolder )
        return _bytesComplitedString;
    
    return formatByteCount(self.bytesComplited);
}

- (BOOL)wanted
{
    if( !_isFolder )
        return _wanted;
    
    [self calcStats];
    return _allFilesWanted;
}

- (void)setWanted:(BOOL)wanted
{
    if( !_isFolder )
    {
        _wanted = wanted;
    }
    else
    {
        _allFilesWanted = wanted;
        for( FSItem *i in _items )
            i.wanted = wanted;
    }
}

- (float)downloadProgress
{
    if( !_isFolder )
        return _downloadProgress;
    
    [self calcStats];
    
    double progress = 0;
    if( _filesLength > 0 )
        progress = (double)_filesBytesComplited / (double)_filesLength;
    
    return (float)progress;
}

- (NSString *)downloadProgressString
{
    if( !_isFolder )
        return _downloadProgressString;
    
    return [NSString stringWithFormat:@"%03.2f%%", self.downloadProgress * 100.0f];
}

- (void)calcStats
{
    if( _needToCalcStats )
    {
        _filesCount = 0;
        _filesLength = 0;
        _filesBytesComplited = 0;
        _allFilesWanted = YES;
        _subfoldersCount = 0;
        _needToCalcStats = NO;
        
        [self traverseAndCount:self];
    }
}

- (void)setNeedToRecalcStats
{
    _needToCalcStats = YES;
    
    if( _isFolder )
        for( FSItem *i in _items )
            [i setNeedToRecalcStats];
}

- (void)traverseAndCount:(FSItem*)item
{
    if( item.isFolder )
    {
        for( FSItem *i in item.items )
        {
            if( i.isFile )
            {
                _filesCount++;
                _filesLength += i.length;
                _filesBytesComplited += i.bytesComplited;
                    
                if( !i.wanted )
                    _allFilesWanted = NO;
            }
            else
            {
                _subfoldersCount++;
                [self traverseAndCount:i];
            }
        }
    }
}

- (NSArray*)rpcFileIndexesUnwanted
{
    NSMutableArray *indexes = nil;
    
    if ( _isFolder )
    {
        indexes = [NSMutableArray array];
        for( FSItem *i in _items )
        {
            if( i.isFile && !i.wanted )
            {
                [indexes addObject:@(i.rpcIndex)];
            }
            else
            {
                [indexes addObjectsFromArray:i.rpcFileIndexesUnwanted];
            }
        }
    }
    
    return indexes;
}

- (NSArray*)rpcFileIndexesWanted
{
    NSMutableArray *indexes = nil;
    
    if ( _isFolder )
    {
        indexes = [NSMutableArray array];
        for( FSItem *i in _items )
        {
            if( i.isFile && i.wanted )
            {
                [indexes addObject:@(i.rpcIndex)];
            }
            else
            {
                [indexes addObjectsFromArray:i.rpcFileIndexesWanted];
            }
        }
    }
    
    return indexes;
}

- (NSArray *)rpcFileIndexes
{
    NSMutableArray *indexes = nil;
    
    if ( _isFolder )
    {
        indexes =  [NSMutableArray array];
        for( FSItem *i in _items )
        {
            if( i.isFile )
            {
                [indexes addObject:@(i.rpcIndex)];
            }
            else
            {
                [indexes addObjectsFromArray:i.rpcFileIndexes];
            }
        }
    }
    
    return indexes;
}

- (BOOL)isFile
{
    return !_isFolder;
}

// add item to children, if it is already exists
// return existing item
- (FSItem *)addItemWithName:(NSString *)name isFolder:(BOOL)isFolder
{
    FSItem *item = [FSItem itemWithName:name isFolder:isFolder];
    
    item.level = _level + 1;
    item.parent = self;
    
    [_items addObject:item];
    
    return item;
}

- (NSString *)description
{
    NSMutableString *spaces = [NSMutableString string];
    for (int i = 0; i < _level; i++)
        [spaces appendString:@"  "];
    
    if( !_isFolder )
        return [NSString stringWithFormat:@"%@%@!\n",spaces, _name];
    
    NSMutableString *s = [NSMutableString stringWithFormat:@"%@/%@\n",spaces, _name];
    
    if( !_collapsed )
        for( FSItem* item in _items )
            [s appendString: item.description];
    
    return s;
}

- (void)sort
{
    if( _isFolder )
    {
        [_items sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             FSItem *item1 = (FSItem*)obj1;
             FSItem *item2 = (FSItem*)obj2;
             
             // if bouth item are folders return comparison result
             if( item1.isFolder && item2.isFolder )
                 return [item1.name compare:item2.name];
             
             // folders first
             if ( item1.isFolder && item2.isFile )
                 return NSOrderedAscending;
             
             if( item1.isFile && item2.isFolder )
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
    FSItem      *_root;
    FSItem      *_foundItemAtIndex;
    
    int         _curIndex;
    int         _findIndex;
    
    NSInteger   _curSection;
    
    BOOL        _itemFound;
    
    NSMutableDictionary *_folderItems;
    
    NSMutableArray *_indexTable;
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
        _root = [FSItem itemWithName:@"" isFolder:YES];      // init root element (always folder)
        _root.rowIndex = -1;
        _folderItems = [NSMutableDictionary dictionary];
        _indexTable = [NSMutableArray array];
    }
    
    return self;
}

- (FSItem *)rootItem
{
    return _root;
}

- (FSItem *)nextItem
{
    return nil;
}

- (void)recalcRowIndexes
{
    _curIndex = -1;
    [_indexTable removeAllObjects];
    [self recalcRowIndexesFromItem:_root];
}

- (void)recalcRowIndexesFromItem:(FSItem *)item
{
    for( FSItem *i in item.items )
    {
        _curIndex++;
        _indexTable[_curIndex] = i;
        i.rowIndex = _curIndex;

        if( i.isFolder && !i.isCollapsed )
            [self recalcRowIndexesFromItem:i];
    }
}

// add file to tree
// file is a path with format /root/subfolder/.../filename it
// should be from root
- (FSItem*)addFilePath:(NSString*)path andRpcIndex:(int)rpcIndex
{
    // split the path string
    NSArray *pathComponents = [path componentsSeparatedByString:PATH_SPLITTER_STRING];
    
    return [self addPathComonents:pathComponents andRpcIndex:rpcIndex];
}

// add file from JSON
- (FSItem *)addItemWithJSONFileInfo:(NSDictionary *)fileInfo JSONFileStatInfo:(NSDictionary *)fileStatInfo rpcIndex:(int)rpcIndex
{
    NSString *fullName = fileInfo[TR_ARG_FILEINFO_NAME];
    
    FSItem *curItem = [self addFilePath:fullName andRpcIndex:rpcIndex];

    curItem.rpcIndex = rpcIndex;
    curItem.fullName = fullName;
    
    long long bytesComplited = [fileInfo[TR_ARG_FILEINFO_BYTESCOMPLETED] longLongValue];
    long long length = [fileInfo[TR_ARG_FILEINFO_LENGTH] longLongValue];
    
    curItem.length = length;
    curItem.bytesComplited = bytesComplited;
    
    curItem.wanted = [fileStatInfo[TR_ARG_FILEINFO_WANTED] boolValue];
    curItem.priority = [fileStatInfo[TR_ARG_FILEINFO_PRIORITY] intValue];
    
    return curItem;
}

- (FSItem *)addPathComonents:(NSArray *)pathComponents andRpcIndex:(int)rpcIndex
{
    // add all components to the tree (from root)
    FSItem* levelItem = _root;
    
    NSUInteger c = pathComponents.count;

    NSMutableString *cPath = [NSMutableString string];
    
    for( int level = 0; level < c; level++ )
    {
        NSString *itemName = pathComponents[level];
        
        // last item in array is file, the others - folders
        BOOL isFolder = ( level != (c - 1) );
        
        [cPath appendString:itemName];
        [cPath appendString:@"/"];

        if( isFolder && _folderItems[cPath] )
        {
            levelItem = _folderItems[cPath];
            continue;
        }
        
        levelItem = [levelItem addItemWithName:itemName isFolder:isFolder];
        
        // cache folder item
        if( isFolder )
        {
            _folderItems[cPath] = levelItem;
            levelItem.fullName = [cPath substringToIndex:(cPath.length - 1)];
            
            //NSLog(@"%@", levelItem.fullName);
        }
        else
            levelItem.rpcIndex = rpcIndex;
    }
    
    return levelItem;
}


- (FSItem*)itemAtIndex:(NSInteger)index
{
    return _indexTable[index];
    
    
//    _curIndex = -1;
//    _findIndex = index;
//    _foundItemAtIndex = nil;
//    
//    [self stepAndInrementFromItem:_root];
//    
//    return _foundItemAtIndex;
}

- (NSInteger)count
{
    return _indexTable.count;
    
//    _curIndex = 0;
//    _findIndex = -1;
//    _foundItemAtIndex = nil;
//    
//    [self stepAndInrementFromItem:_root];
//    return _curIndex;
}

- (void)stepAndInrementFromItem:(FSItem*)item
{
    for( FSItem *i in item.items )
    {
        _curIndex++;
        if( _curIndex == _findIndex )
        {
            _foundItemAtIndex = i;
            return;
        }
        
        if( i.isFolder && !i.isCollapsed )
            [self stepAndInrementFromItem:i];
    }
}

- (NSInteger)indexForItem:(FSItem *)item
{
    return item.rowIndex;
    
//    if( item == _root )
//        return FSITEM_INDEXNOTFOUND;
//    
//    _curIndex = FSITEM_INDEXNOTFOUND;
//    _foundItemAtIndex = item;
//    _itemFound = NO;
//    
//    [self stepAndFindIndexFromItem:_root];
//    
//    return _itemFound ? _curIndex :FSITEM_INDEXNOTFOUND;
}

- (void)stepAndFindIndexFromItem:(FSItem *)item
{
    for( FSItem *i in item.items )
    {
        if( _itemFound )
            return;
        
        _curIndex++;
        if( i == _foundItemAtIndex )
        {
            _itemFound = YES;
            return;
        }
        
        if( i.isFolder && !i.isCollapsed )
            [self stepAndFindIndexFromItem:i];
    }
}

- (NSArray *)childIndexesForItem:(FSItem *)item startRow:(NSInteger)startRow section:(NSInteger)section
{
    _curIndex = (int)startRow;
    _curSection = section;
    
    NSMutableArray *indexes = [NSMutableArray array];
    [self stepAndStoreIndexesForSubItemsOfItem:item storeTo:indexes];
    return indexes;
}

- (void)stepAndStoreIndexesForSubItemsOfItem:(FSItem *)item storeTo:(NSMutableArray *)indexes
{
    for( FSItem *i in item.items )
    {
        _curIndex++;
        
        [indexes addObject:[NSIndexPath indexPathForRow:_curIndex inSection:_curSection]];
        
        if( i.isFolder && !i.isCollapsed )
            [self stepAndStoreIndexesForSubItemsOfItem:i storeTo:indexes];
    }
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
