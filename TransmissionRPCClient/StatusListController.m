//
//  StatusListController.m
//  TransmissionRPCClient
//
//  Shows torrents statueses
//

#import "StatusListController.h"
#import "StatusListCell.h"
#import "TorrentListController.h"
#import "TorrentInfoController.h"
#import "PeerListController.h"
#import "FileListController.h"
#import "TrackerListController.h"
#import "SessionConfigController.h"
#import "SpeedLimitController.h"
#import "PiecesLegendViewController.h"
#import "RPCConnector.h"
#import "FooterViewFreeSpace.h"
#import "HeaderViewDURates.h"
#import "InfoMessage.h"
#import "RateLimitTable.h"
#import "StatusCategories.h"

#define POPOVER_LIMITSPEEDCONTROLLER_SIZE   CGSizeMake(220,400)


@interface StatusListController () <RPCConnectorDelegate,
                                    TorrentListControllerDelegate,
                                    TorrentInfoControllerDelegate,
                                    PeerListControllerDelegate,
                                    FileListControllerDelegate,
                                    TrackerListControllerDelegate,
                                    SpeedLimitControllerDelegate,
                                    UIAlertViewDelegate,
                                    UIPopoverControllerDelegate,
                                    UISplitViewControllerDelegate>

@end

@implementation StatusListController

{
    RateLimitTable *_ratesDown;  // holds download speed limits (kb/s)
    RateLimitTable *_ratesUp;    // holds uplaod speed limits (kb/s)
    
    NSMutableDictionary *_cells;
    
    // this flag used in ViewDidAppear
    BOOL                    _appearedFirstTime;
    BOOL                    _showCheckItems;              // allows to see "checking" status
    BOOL                    _showErrorItems;              // allows to see "error" status
    
    // holds main RPC connector
    RPCConnector            *_connector;
    
    TRSessionInfo           *_sessionInfo;                 // holds session configuration Information
    
    NSTimer                 *_refreshTimer;                // holds main autorefresh timer
    
    // Header/Footer info views
    FooterViewFreeSpace     *_footerViewFreeSpace;
    HeaderViewDURates       *_headerViewDURates;
    
    // toolbar buttons
    UIBarButtonItem         *_btnRefresh;
    UIBarButtonItem         *_btnToggleAltLimits;
    UIBarButtonItem         *_btnLimitDownSpeed;
    UIBarButtonItem         *_btnLimitUpSpeed;
    UIBarButtonItem         *_btnSessionConfig;
    UIBarButtonItem         *_btnSpacer;

    // controllers
    TorrentListController   *_torrentController;          // holds detail torrent list controller
    TorrentInfoController   *_torrentInfoController;      // holds torrent info controller (when torrent is selected from torrent list)
    PeerListController      *_peerListController;         // holds controller for showing peers
    FileListController      *_fileListController;         // holds controller for showing files
    TrackerListController   *_trackerListController;      // holds controller for showing trackers
    PiecesLegendViewController *_piecesController;        // holds pieces legend controller
    
    SessionConfigController *_sessionConfigController;    // holds session config controller
    SpeedLimitController    *_speedLimitController;       // holds speed limit controller
    UIPopoverController     *_speedPopOver;               // holds popover for speed controller
    
    // categories
    StatusCategories        *_items;                      // holds status categories
    StatusCategory          *_selectedCategory;           // selected category
    TRInfos                 *_prevTRInfos;                // holds the previous torrents info
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init all main categories (main model for this view)
    _items = [[StatusCategories alloc] init];
    
    _appearedFirstTime = YES;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // initialize speed limit tables with names
    [self initSpeedLimitTables];
    
    // create RPC connector to communicate with selected server
    if( self.config )
    {        
        _connector = [[RPCConnector alloc] initWithConfig:self.config andDelegate:self];
        
        // config pull-to refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(autorefreshTimerUpdateHandler)
                      forControlEvents:UIControlEventValueChanged];
        
        // schedule autorefresh timer
        if( self.config.refreshTimeout > 0 )
        {
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.config.refreshTimeout target:self
                                                           selector:@selector(autorefreshTimerUpdateHandler)
                                                           userInfo:nil
                                                            repeats:YES];
        }
        else
        {
            self.footerInfoMessage = NSLocalizedString( @"Autorefreshing is off.\nPull down to refresh data.", @"");
        }
    }
    
    // getting detail controller - TorrentListController
    // on iPad it is already created on start
    // on iPhone it should be created from storyboard
    if( self.splitViewController )
    {
        // left (detail) controller should be NavigationContoller with our TorrentListController
        UINavigationController *rightNav = self.splitViewController.viewControllers[1];
        
        _torrentController = (TorrentListController*)rightNav.topViewController;
        // clear all current torrents
        //_torrentController.torrents = nil;
        _torrentController.items = nil;
    }
    else
    {
        // on iPhone instantiate this controller
        _torrentController = instantiateController( CONTROLLER_ID_TORRENTLIST );
    }
    
    // set us as delegate
    _torrentController.delegate = self;
    
    // Configure pull-to-refresh control for updating TorrentListController
    _torrentController.refreshControl = [[UIRefreshControl alloc] init];
    [_torrentController.refreshControl addTarget:self
                                          action:@selector(autorefreshTimerUpdateHandler)
                                forControlEvents:UIControlEventValueChanged];
    
    self.headerInfoMessage = NSLocalizedString( @"Updating ...", @"StatusList header title");
    
    // configure bottom toolbar buttons
    _btnRefresh = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconRefresh20x20"]
                                                   style:UIBarButtonItemStylePlain target:self
                                                  action:@selector(autorefreshTimerUpdateHandler)];
    
    _btnToggleAltLimits = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconTurtleBlack22x22"]
                                                           style:UIBarButtonItemStylePlain target:self
                                                          action:@selector(toggleAltLimits)];
    
    _btnLimitUpSpeed = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconTurtleUpload20x20"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(showUploadLimitRateController:)];
    
    _btnLimitDownSpeed = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconTurtleDownload20x20"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showDownloadLimitRateController:)];
    
    _btnSessionConfig = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconGears20x20"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showSessionConfiguration)];
    
    _btnSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    
    _btnLimitDownSpeed.enabled =  NO;
    _btnLimitUpSpeed.enabled = NO;
    _btnToggleAltLimits.enabled = NO;
    _btnSessionConfig.enabled = NO;
    
    self.toolbarItems = @[ _btnRefresh, _btnSpacer, _btnLimitUpSpeed, _btnSpacer, _btnLimitDownSpeed, _btnSpacer, _btnToggleAltLimits, _btnSpacer, _btnSessionConfig];
    
       // configure "add torrent by url" right nav button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconLinkAdd20x20"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showAddTorrentByURLDialog)];
    
    // hide check and error statuses
    _showCheckItems = NO;
    _showErrorItems = NO;
}

- (void)initSpeedLimitTables
{
    // UP rate limits
    NSArray *titles = @[ NSLocalizedString(@"Unlimited", @"Speed limit"),
                         NSLocalizedString(@"50 Kb/s", @""),
                         NSLocalizedString(@"100 Kb/s", @""),
                         NSLocalizedString(@"150 Kb/s", @""),
                         NSLocalizedString(@"200 Kb/s", @""),
                         NSLocalizedString(@"250 Kb/s", @""),
                         NSLocalizedString(@"500 Kb/s", @""),
                         NSLocalizedString(@"750 Kb/s", @""),
                         NSLocalizedString(@"1024 Kb/s", @""),
                         NSLocalizedString(@"2048 Kb/s", @"") ];
    
    NSArray *rates  = @[ @(0),   @(50),  @(100), @(150),
                         @(200), @(250), @(500),
                         @(750), @(1024),@(2048) ];
    
    _ratesDown = [RateLimitTable tableWithTitles:titles andRates:rates];
    _ratesUp = [RateLimitTable tableWithTitles:titles andRates:rates];
    
    _ratesDown.tableTitle = NSLocalizedString( @"Limit download speed", @"Speed limit table header" );
    _ratesUp.tableTitle =  NSLocalizedString( @"Limit upload speed", @"Speed limit table header" );
}

- (void)showInfoPopup:(NSString*)infoStr
{
    UIView *v = self.parentViewController.view;

    float factor = 1.2;
    float h = 50;
    
    if( self.splitViewController )
    {
        factor = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? 1.8 : 2.3;
        v = self.splitViewController.view;
    }

    InfoMessage *msg = [InfoMessage infoMessageWithSize:CGSizeMake(v.bounds.size.width/factor, h)];
    [msg showInfo:infoStr fromView:v];
}

- (void)showErrorPopup:(NSString*)errStr
{
    UIView *v = self.parentViewController.view;
    
    float factor = 1.2;
    float h = 50;
    
    if( self.splitViewController )
    {
        factor = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? 1.8 : 2.3;
        v = self.splitViewController.view;
    }
    
    InfoMessage *msg = [InfoMessage infoMessageWithSize:CGSizeMake(v.bounds.size.width/factor, h)];
    [msg showErrorInfo:errStr fromView:v];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if there is a leftbutton on _torrentConroller -> change title
    if( self.splitViewController )
    {
        _torrentController.popoverButtonTitle = self.title;
    }
    
    // check if it is ipad we shoud and none of rows is selected - select all row (0)
    if( _appearedFirstTime )
    {
         if( self.splitViewController )
            [self selectRowAtIndex:0];
        
        [_connector getAllTorrents];
        [_connector getSessionInfo];
        
        _appearedFirstTime = NO;
    }
    
    self.navigationController.toolbarHidden = NO;
    
    [self fixFooterHeaderViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)stopUpdating
{
    [_refreshTimer invalidate];
    [_connector stopRequests];
    
    _torrentController.refreshControl = nil;
    _torrentController.infoMessage =  NSLocalizedString( @"There is no selected server", @"BgMessage" );
}

// main refresh cycle, updates data in detail view controllers
- (void)autorefreshTimerUpdateHandler
{
    [_connector getAllTorrents];
   
    UINavigationController *nav = _torrentController.navigationController;
    UIViewController *top = nav.topViewController;
    
    if( top == _torrentInfoController )
    {
        [_connector getDetailedInfoForTorrentWithId:_torrentInfoController.torrentId];
    }
    else if( top == _peerListController)
    {
        [_connector getAllPeersForTorrentWithId:_peerListController.torrentId];
    }
    else if( top == _fileListController )
    {
        if( !_fileListController.isFullyLoaded )
            [_connector getAllFileStatsForTorrentWithId:_fileListController.torrentId];
        //[_connector getAllFilesForTorrentWithId:_fileListController.torrentId];
    }
    else if( top == _trackerListController )
    {
        [_connector getAllTrackersForTorrentWithId:_trackerListController.torrentId];
    }
    else if( top == _piecesController )
    {
        [_connector getPiecesBitMapForTorrent:_piecesController.torrentId];
    }
}

- (void)gotFreeSpaceString:(NSString *)freeSpace
{
    //NSLog(@"gotFreeSpace");
    NSString *str = [NSString stringWithFormat: NSLocalizedString( @"Free space: %@", @"Free space fotter message" ),
                     freeSpace];
    
    //self.footerInfoMessage = str;
    [self showFreeSpaceInfoWithString:str];
    
    if( !self.splitViewController )
        _torrentController.footerInfoMessage = str;
}

- (void)showFreeSpaceInfoWithString:(NSString*)string
{
    if( !_footerViewFreeSpace )
    {
        _footerViewFreeSpace = [FooterViewFreeSpace view];
        self.tableView.tableFooterView = _footerViewFreeSpace;
    }
    
    if( self.tableView.tableFooterView != _footerViewFreeSpace )
        self.tableView.tableFooterView = _footerViewFreeSpace;
    
    _footerViewFreeSpace.label.text = string;
}

- (void)showHeaderDLRate:(TRInfos *)torrents //(NSString*)dlRate ULRate:(NSString*)ulRate
{
    if( !_headerViewDURates )
    {
        _headerViewDURates = [HeaderViewDURates view];
        self.tableView.tableHeaderView = _headerViewDURates;
    }
  
    // fix - hide error message
    if( self.tableView.tableHeaderView != _headerViewDURates )
        self.tableView.tableHeaderView = _headerViewDURates;
    
    _headerViewDURates.uploadString = torrents.totalUploadRateString;
    _headerViewDURates.downloadString = torrents.totalDownloadRateString;

    torrents.totalDownloadRate > 0 ? [_headerViewDURates.iconDL playDownloadAnimation] : [_headerViewDURates.iconDL stopDownloadAnimation];
    torrents.totalUploadRate > 0 ? [_headerViewDURates.iconUL playUploadAnimation] : [_headerViewDURates.iconUL stopUploadAnimation];
}

- (void)fixFooterHeaderViews
{
    if( _footerViewFreeSpace )
    {
        [_footerViewFreeSpace setBoundsFromTableView:self.tableView];
        self.tableView.tableFooterView = _footerViewFreeSpace;
    }
    if( _headerViewDURates )
    {
        [_headerViewDURates setBoundsFromTableView:self.tableView];
        self.tableView.tableHeaderView = _headerViewDURates;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self fixFooterHeaderViews];
}

// should be performed when there is no errors
// occured upon rpc request
- (void)requestToServerSucceeded
{
    UIViewController *topVC = _torrentController.navigationController.topViewController;
    
    if( [topVC isKindOfClass:[CommonTableController class]] )
    {
        CommonTableController *ctc = (CommonTableController*)topVC;
        [ctc.refreshControl endRefreshing];
        ctc.errorMessage = nil;
    }

    [self.refreshControl endRefreshing];
}

// got all torrents, refresh statues
// this is a delegate method, performed asychronosly
// from RPCConnector
- (void)gotAllTorrents:(TRInfos *)torrents
{
    [self requestToServerSucceeded];
    
    NSArray *arr;
    
    arr = [_items updateForDeleteWithInfos:torrents];
    if( arr.count > 0 )
    {
        NSMutableArray *indexPathsToDelete = [NSMutableArray array];
        for( NSNumber* n in arr )
        {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:[n intValue] inSection:0]];
        }
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    
    arr = [_items updateForInsertWithInfos: torrents];
    if( arr.count > 0 )
    {
        NSMutableArray *indexPathsToInsert = [NSMutableArray array];
        for( NSNumber* n in arr )
        {
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:[n intValue] inSection:0]];
        }
        
        [self.tableView beginUpdates];
        
        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    
    // update numbers
    // animate icons
    for( int i = 0; i < _items.countOfVisible; i++ )
    {
        StatusCategory *c = [_items categoryAtIndex:i];
        
        StatusListCell *cell = (StatusListCell*)c.cell;
        cell.numberLabel.text = [NSString stringWithFormat:@"%i", c.count];
        
        IconCloudType iconType = c.iconType;
        
        /// if there are active torrents always animate icon
        if( iconType == IconCloudTypeActive )
            c.count > 0 ? [cell.icon playActivityAnimation] : [cell.icon stopActivityAnimation];
        
        /// if there are checking torrents always animate icon
        else if( iconType == IconCloudTypeCheck )
            c.count > 0 ? [cell.icon playCheckAnimation] : [cell.icon stopCheckAnimation];
        
        /// if there are some downloading torrents and rate more then 0 - animate icon
        else if( iconType == IconCloudTypeDownload )
            torrents.totalDownloadRate > 0 ? [cell.icon playDownloadAnimation] : [cell.icon stopDownloadAnimation ];
        
        /// if threre are some seeding torrents, animate icon only if some of these torents have upload rate > 0
        else if( iconType == IconCloudTypeUpload )
        {
            // FIX: Animate only if there are finished seeding torrents
            BOOL bAnimate = NO;
            for( TRInfo *i in torrents.seedingTorrents )
            {
                if( i.uploadRate > 0 )
                {
                    // no need to continue
                    bAnimate = YES;
                    break;
                }
            }
            
            bAnimate ? [cell.icon playUploadAnimation] : [cell.icon stopUploadAnimation];
        }
    }
    
    _torrentController.items = _selectedCategory;
    
    [self showFinishedTorrentsWithInfo:torrents];

    [self showHeaderDLRate:torrents]; // torrents.totalDownloadRateString ULRate:torrents.totalUploadRateString];
    
//    if( !self.splitViewController )
//    {
//        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"↑UL:%@ ↓DL:%@", @""),
//                         torrents.totalUploadRateString,
//                         torrents.totalDownloadRateString];
//
//        _torrentController.headerInfoMessage = str;
//    }
    
    if( _config.showFreeSpace && _sessionInfo && self.navigationController.visibleViewController == self )
        [_connector getFreeSpaceWithDownloadDir:_sessionInfo.downloadDir];
}

- (void)toggleAltLimits
{
    if( _sessionInfo )
    {
        BOOL toogleMode = !_sessionInfo.altLimitEnabled;
        [_connector toggleAltLimitMode:toogleMode];
    }
}

-(void)gotToggledAltLimitMode:(BOOL)altLimitEnabled
{
    _sessionInfo.altLimitEnabled = altLimitEnabled;
    
     _btnToggleAltLimits.image = altLimitEnabled ? [UIImage imageNamed:@"iconTurtleBlackCrossed22x22"] : [UIImage imageNamed:@"iconTurtleBlack22x22"];
    
    [self showInfoPopup: altLimitEnabled ?  NSLocalizedString(@"Alternative limits is on", @"") :
     NSLocalizedString(@"Alternative limits is off", @"") ];
    
    [_connector getSessionInfo];
}

- (void)showFinishedTorrentsWithInfo:(TRInfos*)torrents
{
    // show torrents in list controller (update)
    // find torrents that are finished downloading
    //TRInfos *prev = _torrentController.torrents;
    if( _prevTRInfos )
    {
        NSArray *dtors = _prevTRInfos.downloadingTorrents;
        NSArray *stors = torrents.seedingTorrents;
        
        NSMutableString *sInfo = [NSMutableString string];
        
        for (TRInfo* dt in dtors)
        {
            for( TRInfo* st in stors )
            {
                if( st.trId == dt.trId )
                {
                    // we have found finished torrent need to
                    [sInfo appendString:[NSString stringWithFormat:NSLocalizedString( @"Torrent: %@\n has finished downloading\n", @""), st.name]];
                }
            }
        }
        
        if( sInfo.length > 0 )
        {
            [self showInfoPopup:sInfo];
        }
        
        // update NsUserDefaults for background fetch notifications
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *currentDownTorrents = torrents.downloadingTorrents;
        if( currentDownTorrents.count > 0 )
        {
            NSMutableArray *downIds = [NSMutableArray array];
            for( TRInfo *t in currentDownTorrents )
                [downIds addObject:@(t.trId)];
            
            [defaults setObject:downIds forKey:USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS];
        }
        else
        {
            [defaults removeObjectForKey:USERDEFAULTS_BGFETCH_KEY_DOWNTORRENTIDS];
        }
        
    } // end of finding finished torrents
    //_torrentController.torrents = torrents;
    _prevTRInfos = torrents;
    
}

// shows alert view for adding torrent by URL (magnet url also)
- (void)showAddTorrentByURLDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Add torrent", @"" )
                                                    message: NSLocalizedString( @"Type URL or MAGNET URL", @"" )
                                                   delegate:self
                                          cancelButtonTitle: NSLocalizedString( @"Cancel", @"" )
                                          otherButtonTitles: NSLocalizedString( @"Add torrent", @""), nil];
    
    alert.delegate = self;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)gotTorrentAdded
{
    [self showInfoPopup: NSLocalizedString(@"New torrent was added",@"float info message")];
}

#pragma mark - UIAlertView delegate methods, add torrent by URL
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex != alertView.cancelButtonIndex )
    {
        // get url
        NSString* urlString = [alertView textFieldAtIndex:0].text;
        [_connector addTorrentWithMagnet:urlString priority:0 startImmidiately:YES];
    }
}

#pragma mark - Bottom toolbar button handlers

- (void)showDownloadLimitRateController:(UIBarButtonItem*)sender
{
    _speedLimitController = instantiateController(CONTROLLER_ID_SPEEDLIMIT);
    _speedLimitController.preferredContentSize = POPOVER_LIMITSPEEDCONTROLLER_SIZE;
    _speedLimitController.rates = _ratesDown;
    _speedLimitController.delegate = self;
    _speedLimitController.title =  NSLocalizedString(@"Download speed limits", @"_speedLimitController title");
    _speedLimitController.isDownload = YES;
    
    if( self.splitViewController )
    {
        if( _speedPopOver && _speedPopOver.isPopoverVisible )
            [_speedPopOver dismissPopoverAnimated:YES];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_speedLimitController];
        _speedPopOver = [[UIPopoverController alloc] initWithContentViewController:nav];
        _speedPopOver.delegate = self;

        [_speedPopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:_speedLimitController animated:YES];
    }
}

- (void)showUploadLimitRateController:(UIBarButtonItem*)sender
{
    _speedLimitController = instantiateController(CONTROLLER_ID_SPEEDLIMIT);
    _speedLimitController.preferredContentSize = POPOVER_LIMITSPEEDCONTROLLER_SIZE;
    _speedLimitController.rates = _ratesUp;
    _speedLimitController.delegate = self;
    _speedLimitController.title =  NSLocalizedString(@"Upload speed limits", @"_speedLimitController title");
    _speedLimitController.isDownload = NO;
    
    if( self.splitViewController )
    {
        if( _speedPopOver && _speedPopOver.isPopoverVisible )
            [_speedPopOver dismissPopoverAnimated:YES];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: _speedLimitController];
        _speedPopOver = [[UIPopoverController alloc] initWithContentViewController:nav];
        _speedPopOver.delegate = self;
        
        [_speedPopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:_speedLimitController animated:YES];
    }
}

- (void)speedLimitControllerSpeedSelectedWithIndex:(int)index
{
    // take limit number and dissmiss
    if( _speedPopOver )
        [_speedPopOver dismissPopoverAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
    // get the limits!
    if( _speedLimitController.isDownload )
    {
        [_connector limitDownloadRateWithSpeed:_ratesDown.selectedRate];
        
        if( _ratesDown.selectedRate == 0)
        {
            [self showInfoPopup: NSLocalizedString(@"Disablilng download speed limit", @"")];
        }
        else
        {
            [self showInfoPopup:[NSString stringWithFormat: NSLocalizedString(@"Setting download speed limit to %i KB/s", @""),
                                 _ratesDown.selectedRate]];
        }
    }
    else
    {
        [_connector limitUploadRateWithSpeed:_ratesUp.selectedRate];
        
        if( _ratesUp.selectedRate == 0)
        {
            [self showInfoPopup: NSLocalizedString(@"Disabling upload speed limit",@"float info")];
        }
        else
        {
            [self showInfoPopup:[NSString stringWithFormat: NSLocalizedString(@"Setting upload speed limit to %i KB/s", @"float info"),
                                 _ratesUp.selectedRate]];
        }
    }
    
    _speedLimitController = nil;
    _speedPopOver = nil;
}

#pragma mark - Working with session information

// shows SessionConfigController and make request
// for session info
- (void)showSessionConfiguration
{
    _sessionConfigController = instantiateController(CONTROLLER_ID_SESSIONCONFIG);
    _sessionConfigController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply", nil)
                                                                                                  style:UIBarButtonItemStylePlain
                                                                                                 target:self
                                                                                                 action:@selector(saveSessionParametes)];
    [self.navigationController pushViewController:_sessionConfigController animated:YES];
    
    [_connector getSessionInfo];
    [_connector portTest];
    
    // FIX: WARNING - don't get it right, but if I put this code
    // above - app is crashing on iOS 8.3 (nsarray is filled with nil)
    // it seems that controls is not loaded
    if( _speedPopOver &&  _speedPopOver.isPopoverVisible )
    {
        [_speedPopOver dismissPopoverAnimated:NO];
        _speedPopOver = nil;
    }
}

- (void)saveSessionParametes
{
    if( [_sessionConfigController saveConfig] )
    {
        [_connector setSessionWithSessionInfo:_sessionConfigController.sessionInfo];
        [self.navigationController popViewControllerAnimated:YES];
        _sessionConfigController = nil;
    }
}

- (void)gotSessionWithInfo:(TRSessionInfo *)info
{
    // getting session information for the first time
    // get free space (fix)
    if( !_sessionInfo && _config.showFreeSpace )
        [_connector getFreeSpaceWithDownloadDir:info.downloadDir];
        
    _sessionInfo = info;
    
    // update session config if controller is on
    // the screen
    if( _sessionConfigController )
        _sessionConfigController.sessionInfo = info;

    // enable buttons
    _btnSessionConfig.enabled = YES;
    _btnLimitDownSpeed.enabled = YES;
    _btnLimitUpSpeed.enabled = YES;
    _btnToggleAltLimits.enabled = YES;
    
    _btnToggleAltLimits.image = info.altLimitEnabled ? [UIImage imageNamed:@"iconTurtleBlackCrossed22x22"] : [UIImage imageNamed:@"iconTurtleBlack22x22"];
    
    // show/hide limit icon
    _headerViewDURates.upLimitIsOn =  info.upLimitEnabled || info.altLimitEnabled;
    _headerViewDURates.downLimitIsOn = info.downLimitEnabled || info.altLimitEnabled;
    
//    NSLog(@"downLimits: %@ ,upLimits: %@",
//          _headerViewDURates.downLimitIsOn ? @"ON":@"OFF",
//          _headerViewDURates.upLimitIsOn ? @"ON":@"OFF");
    
    _ratesUp.selectedRateIndex = 0;
    if( info.upLimitEnabled || info.altLimitEnabled )
    {
        int curRate = _sessionInfo.altLimitEnabled ? _sessionInfo.altUploadRateLimit : _sessionInfo.upLimitRate;
        [_ratesUp updateTableWithRate:curRate];
    }
    
    _ratesDown.selectedRateIndex = 0;
    if( info.downLimitEnabled || info.altLimitEnabled )
    {
        int curRate = _sessionInfo.altLimitEnabled ? _sessionInfo.altDownloadRateLimit : _sessionInfo.downLimitRate;
        [_ratesDown updateTableWithRate:curRate];
    }        
}

- (void)gotPortTestedWithSuccess:(BOOL)portIsOpen
{
    if( _sessionConfigController )
        _sessionConfigController.portIsOpen = portIsOpen;
}

- (void)gotSessionSetWithInfo:(TRSessionInfo *)info
{
    [self gotSessionWithInfo:info];
    [self showInfoPopup: NSLocalizedString(@"Settings have been saved", @"float info message")];
}

#pragma mark - RPCConnector error hangling

/// RPCConnector signals error
- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    // end of refreshing (if it is)
    [self.refreshControl endRefreshing];
    
    // for some errors we show popup message
    if( [requestName isEqualToString:TR_METHODNAME_TORRENTADD] ||
        [requestName isEqualToString:TR_METHODNAME_TORRENTADDURL] )
    {
        [self showErrorPopup:errorMessage];
        return;
    }
    else if ( [requestName isEqualToString:TR_METHODNAME_TESTPORT] )
    {
        [self showErrorPopup:
         [NSString stringWithFormat: NSLocalizedString(@"Can not test port, %@", nil), errorMessage] ];
        return;
    }
    else if( [requestName isEqualToString:TR_METHODNAME_FREESPACE] )
    {
        [self showErrorPopup:
         [NSString stringWithFormat: NSLocalizedString(@"Can not get free space, %@", nil), errorMessage] ];
        return;
    }
    else if( [requestName isEqualToString:TR_METHODNAME_TORRENTSETNAME] )
    {
        [self showErrorPopup:
         [NSString stringWithFormat: NSLocalizedString(@"Can not rename torrent, %@", nil), errorMessage] ];
        return;
    }

    /// show error in top view controller (if it is)
    UIViewController *vc = _torrentController.navigationController.topViewController;
    if( [vc isKindOfClass:[CommonTableController class]] )
    {
        CommonTableController *topVC = (CommonTableController*)vc;
        [topVC.refreshControl endRefreshing];
        
        topVC.errorMessage = errorMessage;
    }

    _torrentController.items = nil;
    self.errorMessage = errorMessage;
}

#pragma mark - TorrentInfoController delegate methods

- (void)showPiecesLegendForTorrentWithId:(int)torrentId piecesCount:(NSInteger)piecesCount pieceSize:(long long)pieceSize
{
    //if( !_piecesController )
    {
        _piecesController = instantiateController( CONTROLLER_ID_PIECESLEGEND );
        _piecesController.pieceSize = pieceSize;
        _piecesController.piecesCount = piecesCount;
        _piecesController.torrentId = torrentId;
        _piecesController.title = NSLocalizedString( @"Torrent pieces bitmap", nil );
        
        UINavigationController *nav = _torrentController.navigationController;
        [nav pushViewController:_piecesController animated:YES];
        
        [_connector getPiecesBitMapForTorrent:torrentId];
    }
}

- (void)gotPiecesBitmap:(NSData *)piecesBitmap forTorrentWithId:(int)torrentId
{
    if( _piecesController )
    {
        _piecesController.piecesBitmap = piecesBitmap;
    }
}

- (void)renameTorrentWithId:(int)torrentId withNewName:(NSString *)newName andPath:(NSString *)path
{
    [_connector renameTorrent:torrentId withName:newName andPath:path];
}

- (void)gotTorrentRenamed:(int)torrentId withName:(NSString *)name andPath:(NSString *)path
{
    [self showInfoPopup: NSLocalizedString(@"Torrent has been renamed", nil)];

    UINavigationController *nav = _torrentController.navigationController;
    
    if( nav.topViewController == _torrentInfoController )
    {
        [_connector getDetailedInfoForTorrentWithId:torrentId];
    }
    else if( nav.topViewController == _fileListController )
    {
        [_connector getAllFilesForTorrentWithId:torrentId];
    }
}

- (void)getMagnetURLforTorrentWithId:(int)torrentId
{
    [_connector getMagnetURLforTorrentWithId:torrentId];
}

- (void)gotMagnetURL:(NSString *)urlString forTorrentWithId:(int)torrentId
{
    if( _torrentInfoController )
    _torrentInfoController.magnetURL = urlString;
}

- (void)stopTorrentWithId:(int)torrentId
{
    //NSLog(@"Stopping torrent");
    
    [_connector stopTorrent:torrentId];
}

- (void)gotTorrentStopedWithId:(int)torrentId
{
    // NSLog(@"%s, id: %i", __PRETTY_FUNCTION__, torrentId);
    
    UIViewController *topVC = _torrentController.navigationController.topViewController;
    
    if( topVC == _torrentInfoController )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            [_connector getDetailedInfoForTorrentWithId:torrentId];
        });
    }
    else if( topVC == _torrentController )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            [_connector getAllTorrents];            
         });
    }
    
    [self showInfoPopup: NSLocalizedString(@"Torrent is stopping ...", @"float info message")];
}

-(void)resumeTorrentWithId:(int)torrentId
{
   // NSLog(@"Resuming torrent");
    
    [_connector resumeTorrent:torrentId];
}

- (void)gotTorrentResumedWithId:(int)torrentId
{
    UIViewController *topVC = _torrentController.navigationController.topViewController;
    
    if( topVC == _torrentInfoController )
        [_connector getDetailedInfoForTorrentWithId:torrentId];
    else if( topVC == _torrentController )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            [_connector getAllTorrents];
         });
    }

    [self showInfoPopup: NSLocalizedString(@"Torrent is starting ...", @"float info message")];
}

-(void)verifyTorrentWithId:(int)torrentId
{
     [_connector verifyTorrent:torrentId];
}

- (void)gotTorrentVerifyedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    [self showInfoPopup:  NSLocalizedString(@"Torrent is verifying ...", @"float info message")];
}

// delegate method from TorrentInfoController
-(void)deleteTorrentWithId:(int)torrentId deleteWithData:(BOOL)deleteWithData
{
    // pop view controller from stack
    UINavigationController *nav = _torrentController.navigationController;
    
    UIViewController *controller = nav.topViewController;

    if( controller == _torrentInfoController )
    {
        [nav popToRootViewControllerAnimated:YES];
        _torrentInfoController = nil;
        
        //NSLog(@"StatusListController: Deleting torrent %@", deleteWithData ? @"with data" : @"");
        
        [_connector deleteTorrentWithId:torrentId deleteWithData:deleteWithData];
    }
}

- (void)torrentListRemoveTorrentWithId:(int)torrentId removeWithData:(BOOL)removeWithData
{
    //NSLog(@"StatusListController: Deleting torrent %i %@", torrentId, removeWithData ? @"with data" : @"");
    
    [_connector deleteTorrentWithId:torrentId deleteWithData:removeWithData];    
}

- (void)gotTorrentDeletedWithId:(int)torrentId
{
    //[_connector getDetailedInfoForTorrentWithId:torrentId];
    [_connector getAllTorrents];
    [self showInfoPopup: NSLocalizedString(@"Torrent was deleted", @"float info message")];
}

- (void)reannounceTorrentWithId:(int)torrentId
{
    //NSLog(@"Reannouncing torrent");
    [_connector reannounceTorrent:torrentId];
}

- (void)gotTorrentReannouncedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    [self showInfoPopup: NSLocalizedString(@"Torrent is reannouncing ...", @"float info message")];
}

- (void)gotTorrentDetailedInfo:(TRInfo *)torrentInfo
{
    if( _torrentInfoController && _torrentInfoController.torrentId == torrentInfo.trId )
    {
        [_torrentInfoController updateData:torrentInfo];
    }
}

- (void)updateTorrentInfoWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
}

#pragma mark - TorrentListController delegate methods

- (void)torrentListStopTorrentWithId:(int)torrentId
{
    [_connector stopTorrent:torrentId];
}

- (void)torrentListStopAllTorrents
{
    [_connector stopAllTorrents];
    [self showInfoPopup:NSLocalizedString(@"Stopping all torrents ...", @"") ];
}

- (void)gotAllTorrentsStopped
{
    [_connector getAllTorrents];
}

- (void)torrentListStartAllTorrents
{
    [_connector resumeAllTorrents];
    [self showInfoPopup:NSLocalizedString(@"Starting all torrents ...", @"") ];
}

- (void)gotAlltorrentsResumed
{
    [_connector getAllTorrents];
}

- (void)torrentListResumeTorrentWithId:(int)torrentId
{
    [_connector resumeTorrent:torrentId];
}

// shows view controller with detailed info
- (void)showDetailedInfoForTorrentWithId:(int)torrentId
{
    _torrentInfoController = instantiateController( CONTROLLER_ID_TORRENTINFO );
    _torrentInfoController.torrentId = torrentId;
    _torrentInfoController.delegate = self;
    _torrentInfoController.title = NSLocalizedString(@"Torrent details", nil);
    
    // we should make a request to RPCConnector
    // (upon complite, info controller will be updated)
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    
    // and show our controller
    // get nav controller for detail panel
    UINavigationController *nav = _torrentController.navigationController;
    // and push this info controller on top of it
    
    [nav pushViewController:_torrentInfoController animated:YES];
}

#pragma mark - PeerListControllerDelegate

- (void)showPeersForTorrentWithId:(int)torrentId
{
    _peerListController = instantiateController( CONTROLLER_ID_PEERLIST );
    _peerListController.delegate = self;
    _peerListController.torrentId = torrentId;
    _peerListController.title =  NSLocalizedString(@"Peers", @"_peerListController title");
    _peerListController.infoMessage = NSLocalizedString(@"Getting peers ...", nil);
    
    UINavigationController *nav = _torrentController.navigationController;
    [nav pushViewController:_peerListController animated:YES];
    
    [_connector getAllPeersForTorrentWithId:torrentId];
}

- (void)gotAllPeers:(NSArray *)peerInfos withPeerStat:(TRPeerStat *)stat forTorrentWithId:(int)torrentId
{
    if( _peerListController )
    {
        [_peerListController updateWithPeers:peerInfos andPeerStat:stat];
    }
}

- (void)peerListNeedUpdatePeersForTorrentId:(int)torrentId
{
    [_connector getAllPeersForTorrentWithId:torrentId];
}

#pragma mark - FileListControllerDelegate methods

- (void)showFilesForTorrentWithId:(int)torrentId
{
    _fileListController = instantiateController( CONTROLLER_ID_FILELIST );
    _fileListController.delegate = self;
    _fileListController.torrentId = torrentId;
    _fileListController.title =  NSLocalizedString(@"Files", @"_fileListController title");
    
    UINavigationController *nav = _torrentController.navigationController;
    [nav pushViewController:_fileListController animated:YES];
    
    _fileListController.infoMessage = NSLocalizedString(@"Getting files for torrent ...", @"");
    
    // make first request to ge all file infos for torrent
    [_connector getAllFilesForTorrentWithId:torrentId];
}

- (void)gotAllFiles:(FSDirectory *)fsDir forTorrentWithId:(int)torrentId
{
    if( _fileListController )
    {
        _fileListController.infoMessage = nil;
        _fileListController.fsDir = fsDir;
    }
}

- (void)gotAllFileStats:(NSArray *)fileStats forTorrentWithId:(int)torrentId
{
    if( _fileListController )
    {
        _fileListController.fileStats =fileStats;
    }
}

- (void)fileListControllerRenameTorrent:(int)torrentId oldItemName:(NSString *)oldItemName newItemName:(NSString *)newItemName
{
    [_connector renameTorrent:torrentId withName:newItemName andPath:oldItemName];
}

- (void)fileListControllerNeedUpdateFilesForTorrentWithId:(int)torrentId
{
    [_connector getAllFileStatsForTorrentWithId:torrentId];
}

- (void)fileListControllerResumeDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    [_connector resumeDownloadingFilesWithIndexes:indexes forTorrentWithId:torrentId];
}

- (void)gotFilesResumedToDownload:(NSArray *)filesIndexes forTorrentWithId:(int)torrentId
{
    if( _fileListController )
    {
        [_fileListController resumedToDownloadFilesWithIndexes:filesIndexes];
    }
}

- (void)fileListControllerStopDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    [_connector stopDownloadingFilesWithIndexes:indexes forTorrentWithId:torrentId];
}

- (void)gotFilesStoppedToDownload:(NSArray *)filesIndexes forTorrentWithId:(int)torrentId
{
    if( _fileListController )
    {
        [_fileListController stoppedToDownloadFilesWithIndexes:filesIndexes];
    }
}

- (void)fileListControllerSetPriority:(int)priority forFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    [_connector setPriority:priority forFilesWithIndexes:indexes forTorrentWithId:torrentId];
}

#pragma mark - TrackerListControllerDelegate methods

- (void)showTrackersForTorrentWithId:(int)torrentId
{
    _trackerListController = instantiateController(CONTROLLER_ID_TRACKERLIST);
    _trackerListController.delegate = self;
    _trackerListController.torrentId = torrentId;
    _trackerListController.title = NSLocalizedString(@"Trackers", @"");
    
    UINavigationController *nav = _torrentController.navigationController;
    [nav pushViewController:_trackerListController animated:YES];
    
    [_connector getAllTrackersForTorrentWithId:torrentId];
}

- (void)gotAllTrackers:(NSArray *)trackerStats forTorrentWithId:(int)torrentId
{
    if( _trackerListController )
        _trackerListController.trackers = trackerStats;
}

- (void)trackerListNeedUpdateDataForTorrentWithId:(int)torrentId
{
    [_connector getAllTrackersForTorrentWithId:torrentId];
}

- (void)trackerListRemoveTracker:(int)trackerId forTorrent:(int)torrentId
{
    [_connector removeTracker:trackerId forTorrent:torrentId];
}

- (void)gotTrackerRemoved:(int)trackerId forTorrentWithId:(int)torrentId
{
    [self showInfoPopup:NSLocalizedString(@"Tracker has been removed", @"")];
    [_connector getAllTrackersForTorrentWithId:torrentId];
}

- (void)applyTorrentSettings:(TRInfo *)info forTorrentWithId:(int)torrentId
{
    if( _torrentInfoController )
    {
        UINavigationController *nav = _torrentInfoController.navigationController;
        [nav popViewControllerAnimated:YES];

        //NSLog(@"Setting torrent individual settings ... ");
        [_connector setSettings:info forTorrentWithId:torrentId];
    }
}

- (void)gotSetSettingsForTorrentWithId:(int)torrentId
{
    [self showInfoPopup:NSLocalizedString(@"Torrent settings has been applied", @"")];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRowAtIndex:(int)indexPath.row];
}

- (void)selectRowAtIndex:(int)rowIndex
{
    if( !self.tableView.indexPathForSelectedRow || self.tableView.indexPathForSelectedRow.row != rowIndex )
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:9]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];        
    }
    
    _selectedCategory  = [_items categoryAtIndex: rowIndex];
    
    _torrentController.items = _selectedCategory;
    _torrentController.title = NSLocalizedString(@"Torrents", @"");
    _torrentController.popoverButtonTitle = self.title;
    
    // on iPhone we should show _torrentController instead of ours
    if( !self.splitViewController )
        [self.navigationController pushViewController:_torrentController animated:YES];
    else
        // on iPad show torrent list
        [_torrentController.navigationController popToRootViewControllerAnimated:YES];
    // [_connector getAllTorrents];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Torrents", @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _items.countOfVisible > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.countOfVisible;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatusCategory *c = [_items categoryAtIndex:(int)indexPath.row];
    
    StatusListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_STATUSLIST forIndexPath:indexPath];
    
    // Configure the cell
    cell.numberLabel.text  = @" ";
    cell.statusLabel.text = c.title;
    
    cell.icon.iconType = c.iconType;
    cell.icon.tintColor = c.iconColor ? c.iconColor : cell.tintColor;
      
    // store cell reference for later cell
    // updating
    c.cell = cell;
    
    return cell;
}

@end
