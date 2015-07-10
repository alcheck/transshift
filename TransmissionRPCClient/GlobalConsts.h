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

id instantiateController( NSString* controllerId );