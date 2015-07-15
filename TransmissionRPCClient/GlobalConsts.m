//
//  GlobalConsts.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "GlobalConsts.h"

@implementation UIColor (transmissionColors)

+ (UIColor *)errorColor
{
    return [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1];
}

+ (UIColor *)seedColor
{
    return [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];
}

+ (UIColor *)checkColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)stopColor
{
    return [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:1];
}

+ (UIColor *)progressBarTrackColor
{
    return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
}

@end


@implementation UIImage (transmissionIcons)

+ (UIImage *)iconActive
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"activeIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconAll
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"allIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconCheck
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"checkIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconDownload
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"downloadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconError
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"iconErrorTorrent40x40"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconStop
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"stopIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconUpload
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"uploadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconPlay
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"iconPlay36x36"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

+ (UIImage *)iconPause
{
    static UIImage *icon = nil;
    if( !icon )
        icon = [[UIImage imageNamed:@"iconStop36x36"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return icon;
}

@end


id instantiateController( NSString *controllerId )
{
    static UIStoryboard* storyboard = nil;
    
    if( !storyboard )
    {
        storyboard = [UIStoryboard storyboardWithName:GLOBAL_CONTROLLERS_STORYBOARD bundle:nil];
    }
    
    
    return [storyboard instantiateViewControllerWithIdentifier:controllerId];
}

NSString* formatByteCount(long long byteCount)
{
    static NSByteCountFormatter *formatter = nil;
    
    if( !formatter )
    {
        formatter = [[NSByteCountFormatter alloc] init];
        formatter.allowsNonnumericFormatting = NO;
    }
    
    if( byteCount == 0 )
        return  NSLocalizedString(@"0 KB", @"formatByCount");
    
    return [formatter stringFromByteCount:byteCount];
}

NSString* formatByteRate(long long bytesPerSeconds)
{
    return [NSString stringWithFormat: NSLocalizedString(@"%@/s", @"formatByRate"),
            formatByteCount(bytesPerSeconds)];
}

NSString* formatDateFrom1970(NSTimeInterval seconds)
{
    static NSDateFormatter *formatter = nil;
    
    if( !formatter )
    {
        NSLocale *locale = [NSLocale currentLocale];
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = locale;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
    return [formatter stringFromDate:dt];
}

NSString* formatHoursMinutes(NSTimeInterval seconds)
{
    NSCalendarUnit calendarUnits = (NSCalendarUnit)(NSHourCalendarUnit|NSMinuteCalendarUnit);
    NSDate *dtNow = [NSDate date];
    NSDate *dtFrom = [dtNow dateByAddingTimeInterval:-seconds];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnits fromDate:dtFrom toDate:dtNow options:(NSCalendarOptions)0];
    return [NSString stringWithFormat: NSLocalizedString(@"%ld hours %ld mins", @"formateHoursMinutes"),
            (long)dateComponents.hour, (long)dateComponents.minute];
}



