//
//  TRFileInfo.m
//  TransmissionRPCClient
//
//  Holds information about file
//

#import "TRFileInfo.h"
#import "GlobalConsts.h"

@interface TRFileInfo()

@end

@implementation TRFileInfo

+ (TRFileInfo *)fileInfoFromJSON:(NSDictionary *)dict
{
    return [[TRFileInfo alloc] initFromJSON:dict];
}

- (instancetype)initFromJSON:(NSDictionary*)dict
{
    self = [super init];
    if( !self )
        return self;
    
    if( dict[TR_ARG_FILEINFO_NAME] )
    {
        _name = dict[TR_ARG_FILEINFO_NAME];
        _folderLevel = 0;
        // try to get file name
        NSArray* arr = [_name componentsSeparatedByString:@"/"];
        if( arr && arr.count > 1 )
        {
            _fileName = [arr lastObject];
            _folderLevel = (int)arr.count - 1;
            _parentFolderName = arr[arr.count - 2];
        }
        else
        {
            _fileName = _name;
        }
    }
    
    if ( dict[TR_ARG_FILEINFO_LENGTH] )
    {
        _length = [dict[TR_ARG_FILEINFO_LENGTH] longLongValue];
        _lengthString = formatByteCount(_length);
    }
    
    if( dict[TR_ARG_FILEINFO_BYTESCOMPLETED] )
    {
        _bytesComplited = [dict[TR_ARG_FILEINFO_BYTESCOMPLETED] longLongValue];
        _bytesComplitedString = formatByteCount(_bytesComplited);
    }
    
    if( _length > 0 )
    {
        _downloadProgress = (float)((double)_bytesComplited/(double)_length);
        _downloadProgressString = [NSString stringWithFormat:@"%02.2f%%", _downloadProgress * 100.0f];
    }
    
    if( dict[TR_ARG_FILEINFO_WANTED] )
        _wanted = [dict[TR_ARG_FILEINFO_WANTED] boolValue];
    
    if( dict[TR_ARG_FILEINFO_PRIORITY] )
    {
        _priority = [dict[TR_ARG_FILEINFO_PRIORITY] intValue];
        _priorityString = @"unknown";
        if( _priority == TR_FILEINFO_PRIORITY_NORMAL )
            _priorityString = @"normal";
        else if( _priority == TR_FILEINFO_PRIORITY_LOW )
            _priorityString = @"low";
        else if( _priority == TR_FILEINFO_PRIORITY_HIGH )
            _priorityString = @"high";
    }
    
    return self;
}

@end

@implementation TRFileStat

+ (instancetype)fileStatFromJSON:(NSDictionary *)dict
{
    return [[TRFileStat alloc] initFromJSON: dict];
}

- (instancetype)initFromJSON:(NSDictionary *)dict
{
    self = [super init];
    
    if( !self )
        return self;
    
    if( dict[TR_ARG_FILEINFO_BYTESCOMPLETED] )
    {
        _bytesComplited = [dict[TR_ARG_FILEINFO_BYTESCOMPLETED] longLongValue];
        _bytesComplitedString = formatByteCount(_bytesComplited);
    }
    
    if( dict[TR_ARG_FILEINFO_WANTED] )
        _wanted = [dict[TR_ARG_FILEINFO_WANTED] boolValue];
    
    if( dict[TR_ARG_FILEINFO_PRIORITY] )
        _priority = [dict[TR_ARG_FILEINFO_PRIORITY] intValue];
    
    return self;
}

@end

