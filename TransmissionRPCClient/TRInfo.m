//
//  TRInfo.m
//  TransmissionRPCClient
//
//  Torrent info class

#import "TRInfo.h"

@interface TRInfo()

@end

@implementation TRInfo

// convinience initializer
+ (TRInfo *)infoFromJSON:(NSDictionary *)dict
{
    TRInfo *info = [[TRInfo alloc] initFromJSON:dict];
    return info;
}

// close default initializer
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"TRInfo" reason:@"TRInfo object should be initialized from class method +infoFromJSON:" userInfo:nil];
}

- (instancetype)initFromJSON:(NSDictionary*)dict
{
    self = [super init];
    
    if( self )
    {
        NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc] init];
        byteFormatter.allowsNonnumericFormatting = NO;
        
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = locale;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        if( dict[TR_ARG_FIELDS_NAME] )
            _name = dict[TR_ARG_FIELDS_NAME];
        
        if( dict[TR_ARG_FIELDS_PERCENTDONE] )
        {
            _percentsDone = [(NSNumber*)dict[TR_ARG_FIELDS_PERCENTDONE] floatValue];
            _percentsDoneString = [NSString stringWithFormat:@"%03.2f%%", _percentsDone * 100.0f];
        }
        
        if( dict[TR_ARG_FIELDS_ID] )
            _trId  = [(NSNumber*)dict[TR_ARG_FIELDS_ID] intValue];;
        
        if( dict[TR_ARG_FIELDS_STATUS])
        {
            _status = [(NSNumber*)dict[TR_ARG_FIELDS_STATUS] intValue];
            
            _statusString = @"Unknown";
            if( _status == TR_STATUS_DOWNLOAD || _status == TR_STATUS_DOWNLOAD_WAIT )
            {
                _isDownloading = YES;
                _statusString = @"Downloading";
            }
            
            if( _status == TR_STATUS_CHECK || _status == TR_STATUS_CHECK_WAIT )
            {
                _isChecking = YES;
                _statusString = @"Checking";
            }
            
            if ( _status == TR_STATUS_SEED || _status == TR_STATUS_SEED_WAIT )
            {
                _isSeeding = YES;
                _statusString = @"Seeding";
            }
            
            if( _status == TR_STATUS_STOPPED )
            {
                _isStopped = YES;
                _statusString = @"Stopped";
            }
        }
        
        if( dict[TR_ARG_FIELDS_RECHECKPROGRESS] )
        {
            _recheckProgress = [(NSNumber*)dict[TR_ARG_FIELDS_RECHECKPROGRESS] floatValue];
            _recheckProgressString = [NSString stringWithFormat:@"%03.2f%%", _recheckProgress * 100.0f];
        }
        
        if( dict[TR_ARG_FIELDS_RATEUPLOAD] )
        {
            _uploadRate = [(NSNumber*)dict[TR_ARG_FIELDS_RATEUPLOAD] longLongValue];
            _uploadRateString = [byteFormatter stringFromByteCount:_uploadRate];
        }
        
        if( dict[TR_ARG_FIELDS_RATEDOWNLOAD] )
        {
            _downloadRate = [(NSNumber*)dict[TR_ARG_FIELDS_RATEDOWNLOAD] longLongValue];
            _downloadRateString = [byteFormatter stringFromByteCount:_downloadRate];
        }
        
        if( dict[TR_ARG_FIELDS_DOWNLOADEDEVER] )
        {
            _downloadedEver = [(NSNumber*)dict[TR_ARG_FIELDS_DOWNLOADEDEVER] longLongValue];
            _downloadedEverString = [byteFormatter stringFromByteCount:_downloadedEver];
        }
        
        if( dict[TR_ARG_FIELDS_TOTALSIZE])
        {
            _totalSize  = [(NSNumber*)dict[TR_ARG_FIELDS_TOTALSIZE] longLongValue];
            _totalSizeString = [byteFormatter stringFromByteCount:_totalSize];
            _downloadedSize = (long long)((double)_totalSize * _percentsDone);
            _downloadedSizeString = [byteFormatter stringFromByteCount:_downloadedSize];
        }
        
        if( dict[TR_ARG_FIELDS_HAVEVALID] )
        {
            long long haveValid = [(NSNumber*)dict[TR_ARG_FIELDS_HAVEVALID] longLongValue];
            _haveValidString = [byteFormatter stringFromByteCount:haveValid];
        }
        
        if( dict[TR_ARG_FIELDS_HAVEUNCHECKED] )
        {
            long long haveUnchecked = [(NSNumber*)dict[TR_ARG_FIELDS_HAVEUNCHECKED] longLongValue];
            _haveUncheckedString = [byteFormatter stringFromByteCount:haveUnchecked];
        }
        
        if( dict[TR_ARG_FIELDS_UPLOADEDEVER] )
        {
            _uploadedEver = [(NSNumber*)dict[TR_ARG_FIELDS_UPLOADEDEVER] longLongValue];
            _uploadedEverString = [byteFormatter stringFromByteCount:_uploadedEver];
        }
        
        if( dict[TR_ARG_FIELDS_UPLOADRATIO] )
            _uploadRatio = [(NSNumber*)dict[TR_ARG_FIELDS_UPLOADRATIO] floatValue];
        
        if( dict[TR_ARG_FIELDS_PEERSCONNECTED] )
            _peersConnected = [(NSNumber*)dict[TR_ARG_FIELDS_PEERSCONNECTED] intValue];
        
        if( dict[TR_ARG_FIELDS_PEERSGETTINGFROMUS] )
            _peersGettingFromUs = [(NSNumber*)dict[TR_ARG_FIELDS_PEERSGETTINGFROMUS] intValue];
        
        if( dict[TR_ARG_FIELDS_PEERSSENDINGTOUS] )
            _peersSendingToUs = [(NSNumber*)dict[TR_ARG_FIELDS_PEERSSENDINGTOUS] intValue];
       
        if( dict[TR_ARG_FIELDS_CREATOR])
            _creator = dict[TR_ARG_FIELDS_CREATOR];
        
        if(dict[TR_ARG_FIELDS_ERRORSTRING])
            _errorString = dict[TR_ARG_FIELDS_ERRORSTRING];
        
        if( dict[TR_ARG_FIELDS_ERRORNUM] )
            _errorNumber = [(NSNumber*)dict[TR_ARG_FIELDS_ERRORNUM] intValue];
        
        if(dict[TR_ARG_FIELDS_COMMENT])
            _comment = dict[TR_ARG_FIELDS_COMMENT];
        
        if(dict[TR_ARG_FIELDS_HASHSTRING])
            _hashString = dict[TR_ARG_FIELDS_HASHSTRING];
        
        if(dict[TR_ARG_FIELDS_PIECESIZE])
        {
            _pieceSize = [(NSNumber*)dict[TR_ARG_FIELDS_PIECESIZE] longLongValue];
            _pieceSizeString = [byteFormatter stringFromByteCount:_pieceSize];
        }
        
        if( dict[TR_ARG_FIELDS_PIECECOUNT] )
            _piecesCount = [(NSNumber*)dict[TR_ARG_FIELDS_PIECECOUNT] intValue];
        
        if(dict[TR_ARG_FIELDS_DATECREATED])
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_DATECREATED] doubleValue];
            NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
            _dateCreatedString = [dateFormatter stringFromDate:dt];
        }
        
        if(dict[TR_ARG_FIELDS_ACTIVITYDATE])
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_ACTIVITYDATE] doubleValue];
            NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
            _dateLastActivityString = [dateFormatter stringFromDate:dt];
        }
        
        if(dict[TR_ARG_FIELDS_DONEDATE])
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_DONEDATE] doubleValue];
            NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
            _dateDoneString = [dateFormatter stringFromDate:dt];
        }
        
        if(dict[TR_ARG_FIELDS_STARTDATE])
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_STARTDATE] doubleValue];
            NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
            _dateAddedString = [dateFormatter stringFromDate:dt];
        }
        
        NSDate *dtNow = [NSDate date];
        NSCalendarUnit calendarUnits = (NSCalendarUnit)(NSHourCalendarUnit|NSMinuteCalendarUnit);

        if( dict[TR_ARG_FIELDS_SECONDSSEEDING] )
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_SECONDSSEEDING] doubleValue];
            NSDate *dtFrom = [dtNow dateByAddingTimeInterval:-seconds];
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnits fromDate:dtFrom toDate:dtNow options:(NSCalendarOptions)0];
            _seedingTimeString = [NSString stringWithFormat:@"%ld hours %ld mins", (long)dateComponents.hour, (long)dateComponents.minute];
        }
        
        if( dict[TR_ARG_FIELDS_SECONDSDOWNLOADING] )
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_SECONDSDOWNLOADING] doubleValue];
            NSDate *dtFrom = [dtNow dateByAddingTimeInterval:-seconds];
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnits fromDate:dtFrom toDate:dtNow options:(NSCalendarOptions)0];
            _downloadingTimeString  = [NSString stringWithFormat:@"%ld hours %ld mins", (long)dateComponents.hour, (long)dateComponents.minute];
        }
        
        if( dict[TR_ARG_FIELDS_ETA] )
        {
            NSTimeInterval seconds = [(NSNumber*)dict[TR_ARG_FIELDS_ETA] doubleValue];
            NSDate *dtFrom = [dtNow dateByAddingTimeInterval:-seconds];
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnits fromDate:dtFrom toDate:dtNow options:0];
            
            if( dateComponents.hour !=0 && dateComponents.minute !=0 )
                _etaTimeString = [NSString stringWithFormat:@"%ld hours %ld mins", (long)dateComponents.hour, (long)dateComponents.minute];
            else
                _etaTimeString = @"unknown";
        }
        
        if( dict[TR_ARG_BANDWIDTHPRIORITY] )
        {
            _bandwidthPriority = [(NSNumber*)dict[TR_ARG_BANDWIDTHPRIORITY] intValue];
            _bandwidthPriorityString = (_bandwidthPriority == 0 ) ? @"normal" : ( _bandwidthPriority == -1 ? @"low" : @"high" );
        }

     }
    
    return self;
}


@end
