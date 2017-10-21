//
//  GlobalConsts.h
//  TransmissionRPCClient
//
//  Constants using in all uiviewcontrolles
//

#import <UIKit/UIKit.h>

// TOP + BOTTOM margins of error headers of UITableView
#define TABLEHEADER_ERRORLABEL_TOPBOTTOMMARGIN      40
#define TABLEHEADER_ERRORLABEL_FONTSIZE             15

#define TABLEVIEW_BACKGROUND_MESSAGE_FONTSIZE       19
#define TABLEVIEW_FOOTER_MESSAGE_FONTSIZE           14
#define TABLEVIEW_FOOTER_MESSAGE_TOPBOTTOM_MARGINGS 30

#define TABLEVIEW_HEADER_MESSAGE_TOPBOTTOM_MARGINGS 30
#define TABLEVIEW_HEADER_MESSAGE_FONTSIZE           14


// utility functions
#define GLOBAL_CONTROLLERS_STORYBOARD           @"controllers"


#define USERDEFAULTS_BGFETCH_KEY_RPCCONFG           @"bgCurrentRPCConfig"
#define USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS     @"bgDownloadingTorrentIds"

/// returns YES if this is iPhone PLUS model on iOS8
BOOL isIPhonePlus(void);

/*!
     Set the large title for NavigationBar on iOS11.0+
     @param navVC - UINavigationController to set the title
*/
void preferBigTitleForNavController( UINavigationController *navVC );


/*!
    Retruns the new instance of UIViewController
    from global storyboard
    @param controllerId - storyboardId of the controller
 */
id instantiateController( NSString* controllerId );


/*!
    Returns formatted localized string for count of bytes
    @param count - count of bytes per second
    @return string representation (localized)
 */
NSString* formatByteCount(long long bytes);

/// Returns formatted localized string for rate bytes/second
NSString* formatByteRate(long long bytesPerSeconds);

/// Returns formatted localized date string
NSString* formatDateFrom1970(NSTimeInterval intevalSince1970);
/// Returns formatted localized date/time string - short mode
NSString* formatDateFrom1970Short(NSTimeInterval seconds);

/// Returns formatted localized string of hours and minutes
/// from time interval since 1970
NSString* formatHoursMinutes(NSTimeInterval intervalSince1970);

/// Global colors extension
@interface UIColor(transmissionColors)
//
+ (UIColor*)seedColor;
//+ (UIColor*)downloadColor;
+ (UIColor*)stopColor;
+ (UIColor*)checkColor;
+ (UIColor*)errorColor;
+ (UIColor*)progressBarTrackColor;
//+ (UIColor*)activeColor;
//
@end


@interface UIImage(transmissionIcons)

+ (UIImage*)iconUpload;
+ (UIImage*)iconDownload;
+ (UIImage*)iconStop;
+ (UIImage*)iconCheck;
+ (UIImage*)iconError;
+ (UIImage*)iconActive;
+ (UIImage*)iconAll;
+ (UIImage*)iconPause;
+ (UIImage*)iconPlay;

@end
