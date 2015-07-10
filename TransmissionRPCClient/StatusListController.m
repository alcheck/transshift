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
#import "SessionConfigController.h"
#import "SpeedLimitController.h"
#import "RPCConnector.h"
#import "FooterViewFreeSpace.h"
#import "HeaderViewDURates.h"
#import "InfoMessage.h"

#define STATUS_SECTION_TITILE       @"Torrents"


@interface StatusListController () <RPCConnectorDelegate,
                                    TorrentListControllerDelegate,
                                    TorrentInfoControllerDelegate,
                                    PeerListControllerDelegate,
                                    FileListControllerDelegate,
                                    SpeedLimitControllerDelegate,
                                    UIAlertViewDelegate,
                                    UIPopoverControllerDelegate,
                                    UISplitViewControllerDelegate>

@end

@implementation StatusListController

{
    NSArray *_sections;
    NSArray *_itemNames;
    NSArray *_itemFilterOptions;
    NSArray *_itemImages;
    
    NSArray *_speedUpTitles;  // holds speed titles
    NSArray *_speedUpRates;   // holds speed rates for this titles (Kb/s)

    NSArray *_speedDownTitles;  // holds speed titles
    NSArray *_speedDownRates;   // holds speed rates for this titles (Kb/s)
    
    // selected speed for downloading
    int     _selectedDownloadRateIndex;         // - 0 - not selected
    // selected speed for upoading
    int     _selectedUploadRateIndex;           // - 0 - not selected
    
    NSMutableDictionary *_cells;
    
    // this flag used in ViewDidAppear
    BOOL    _appearedFirstTime;
    
    // holds main RPC connector
    RPCConnector *_connector;
    
    TRSessionInfo          *_sessionInfo;                 // holds session configuration Information
    NSString               *_uploadRateLimitString;
    NSString               *_downloadRateLimitString;
    
    NSTimer *_refreshTimer;                               // holds main autorefresh timer
    
    // Header/Footer info views
    FooterViewFreeSpace     *_footerViewFreeSpace;
    HeaderViewDURates       *_headerViewDURates;

    // controllers

    TorrentListController   *_torrentController;          // holds detail torrent list controller
    TorrentInfoController   *_torrentInfoController;      // holds torrent info controller (when torrent is selected from torrent list)
    PeerListController      *_peerListController;         // holds controller for showing peers
    FileListController      *_fileListController;         // holds controller for showing files
    SessionConfigController *_sessionConfigController;    // holds session config controller
    SpeedLimitController    *_speedLimitController;       // holds speed limit controller
    UIPopoverController     *_speedPopOver;               // holds popover for speed controller
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appearedFirstTime = YES;
    
    // initialize section name and section row names
    [self initNames];
    // initialize speeds
    [self initSpeedTitles];
    
    // create RPC connector to communicate with selected server
    if( self.config )
    {        
        _connector = [[RPCConnector alloc] initWithConfig:self.config andDelegate:self];
        
        // config pull-to refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(autorefreshTimerUpdateHandler)
                      forControlEvents:UIControlEventValueChanged];
        
        // configure autorefresh timer
        if( self.config.refreshTimeout > 0 )
        {
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.config.refreshTimeout target:self
                                                           selector:@selector(autorefreshTimerUpdateHandler)
                                                           userInfo:nil
                                                            repeats:YES];
        }
        else
        {
            self.footerInfoMessage = @"Autorefreshing is off.\nPull down to refresh data.";
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
        _torrentController.torrents = nil;
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
    
    self.headerInfoMessage = @"Updating ...";
    
    // configure bottom toolbar
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconRefresh20x20"]
                                                           style:UIBarButtonItemStylePlain target:self
                                                          action:@selector(autorefreshTimerUpdateHandler)],
                          
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          
                          [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconTurtleUpload20x20"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(showUploadLimitRateController:)],
                          
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          
                          [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconTurtleDownload20x20"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(showDownloadLimitRateController:)],
                          
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          
                          
                          [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconGears20x20"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(showSessionConfiguration)]
                          ];
    
    // configure "add torrent by url" right nav button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconLinkAdd20x20"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showAddTorrentByURLDialog)];
}

- (void)initNames
{
    _sections =          @[ STATUS_SECTION_TITILE ];
    
    _itemNames =         @[ STATUS_ROW_ALL,
                            STATUS_ROW_ACTIVE,
                            STATUS_ROW_DOWNLOAD,
                            STATUS_ROW_SEED,
                            STATUS_ROW_STOP,
                            STATUS_ROW_CHECK ];
    
    _itemFilterOptions = @[ @(TRStatusOptionsAll),
                            @(TRStatusOptionsActive),
                            @(TRStatusOptionsDownload),
                            @(TRStatusOptionsSeed),
                            @(TRStatusOptionsStop),
                            @(TRStatusOptionsCheck) ];
    
    _itemImages =        @[ [UIImage imageNamed:@"allIcon"],
                            [UIImage imageNamed:@"activeIcon"],
                            [UIImage imageNamed:@"downloadIcon"],
                            [UIImage imageNamed:@"uploadIcon"],
                            [UIImage imageNamed:@"stopIcon"],
                            [UIImage imageNamed:@"checkIcon"] ];
    
    _cells = [NSMutableDictionary dictionary];
}

- (void)initSpeedTitles
{
    // UP rate limits
    _speedUpTitles = @[ @"Unlimited", @"50 Kb/s", @"100 Kb/s",  @"150 Kb/s",
                        @"200 Kb/s",  @"250 Kb/s",  @"500 Kb/s",
                        @"750 Kb/s",  @"1024 Kb/s", @"2048 Kb/s" ];
    
    _speedUpRates = @[ @(0),   @(50),  @(100), @(150),
                       @(200), @(250), @(500),
                       @(750), @(1024),@(2048) ];
    
    
    // DOWN  rate limits
    _speedDownTitles = @[ @"Unlimited", @"50 Kb/s", @"100 Kb/s",  @"150 Kb/s",
                          @"200 Kb/s",  @"250 Kb/s",  @"500 Kb/s",
                          @"750 Kb/s",  @"1024 Kb/s", @"2048 Kb/s" ];
    
    _speedDownRates = @[ @(0),   @(50),  @(100), @(150),
                         @(200), @(250), @(500),
                         @(750), @(1024),@(2048) ];

    
    _selectedDownloadRateIndex = 0;
    _selectedUploadRateIndex = 0;
}

// adjusts tables of rate limits
// add new item in tables if needed
- (void)adjustSpeedLimitTables
{
    _selectedUploadRateIndex = 0;
    _selectedDownloadRateIndex = 0;
    
    if( !_sessionInfo )
        return;

    BOOL needToCheck = _sessionInfo.downLimitEnabled || _sessionInfo.upLimitEnabled || _sessionInfo.altLimitEnabled;
    
    if( !needToCheck )
        return;

    // check download speeds
    if( _sessionInfo.downLimitEnabled || _sessionInfo.altLimitEnabled )
    {
        int curRate = _sessionInfo.altLimitEnabled ? _sessionInfo.altDownloadRateLimit : _sessionInfo.downLimitRate;
        
        // search this rate in tables
        BOOL needToInsertNew = YES;
        int  insertIndex = _speedDownRates.count;

        int prevRate = INT_MAX;
        for( int i = 1; i < _speedDownRates.count; i++ ) // start from 1 - skip the first element
        {
            int tableRate = [(NSNumber*)_speedDownRates[i] intValue];
            
            if( tableRate == curRate )
            {
                needToInsertNew = NO;
                _selectedDownloadRateIndex = i;
                break;
            }
            
            if( curRate > prevRate &&  curRate < tableRate )
            {
                insertIndex = i;
                break;
            }
            
            prevRate = tableRate;
        }
        
        if( needToInsertNew )
        {
            // insert new item in table
            NSMutableArray *curRates = [NSMutableArray arrayWithArray:_speedDownRates];
            NSMutableArray *curTitles = [NSMutableArray arrayWithArray:_speedDownTitles];
            
            NSString *newTitle = [NSString stringWithFormat:@"%i Kb/s", curRate];
            
            if( insertIndex >= _speedDownRates.count)
            {
                [curRates addObject:@(curRate)];
                [curTitles addObject:newTitle];
            }
            else
            {
                [curRates insertObject:@(curRate) atIndex: insertIndex];
                [curTitles insertObject:newTitle atIndex: insertIndex];
            }
            
            _selectedDownloadRateIndex = insertIndex;
            
            _speedDownTitles = curTitles;
            _speedDownRates = curRates;
        }
    } // session download speed adjust
    
    // session upload speed adjust
    if( _sessionInfo.upLimitEnabled || _sessionInfo.altLimitEnabled )
    {
        int curRate = _sessionInfo.altLimitEnabled ? _sessionInfo.altUploadRateLimit : _sessionInfo.upLimitRate;
        
        // search this rate in tables
        BOOL needToInsertNew = YES;
        int  insertIndex = _speedUpRates.count;
        
        int prevRate = INT_MAX;
        for( int i = 1; i < _speedUpRates.count; i++ ) // start from 1 - skip the first element
        {
            int tableRate = [(NSNumber*)_speedUpRates[i] intValue];
            
            if( tableRate == curRate )
            {
                needToInsertNew = NO;
                _selectedUploadRateIndex = i;
                break;
            }
            
            if( curRate > prevRate &&  curRate < tableRate )
            {
                insertIndex = i;
                break;
            }
            
            prevRate = tableRate;
        }
        
        if( needToInsertNew )
        {
            // insert new item in table
            NSMutableArray *curRates = [NSMutableArray arrayWithArray:_speedUpRates];
            NSMutableArray *curTitles = [NSMutableArray arrayWithArray:_speedUpTitles];
            
            NSString *newTitle = [NSString stringWithFormat:@"%i Kb/s", curRate];
            
            if( insertIndex >= _speedUpRates.count)
            {
                [curRates addObject:@(curRate)];
                [curTitles addObject:newTitle];
            }
            else
            {
                [curRates insertObject:@(curRate) atIndex: insertIndex];
                [curTitles insertObject:newTitle atIndex: insertIndex];
            }
            
            _selectedUploadRateIndex = insertIndex;
            
            _speedUpTitles = curTitles;
            _speedUpRates = curRates;
        }
    } // session upload speed adjust
}

- (void)showInfoPopup:(NSString*)infoStr
{
    UIView *v = self.parentViewController.view;

    float factor = 1.2;
    if( self.splitViewController )
    {
        factor = 2.3;
        v = self.splitViewController.view;
    }
    
    InfoMessage *msg = [InfoMessage infoMessageWithSize:CGSizeMake(v.bounds.size.width/factor, 50)];
    [msg showInfo:infoStr fromView:v];
}

- (void)showErrorPopup:(NSString*)errStr
{
    UIView *v = self.parentViewController.view;
    
    float factor = 1.2;
    if( self.splitViewController )
    {
        factor = 2.3;
        v = self.splitViewController.view;
    }
    
    InfoMessage *msg = [InfoMessage infoMessageWithSize:CGSizeMake(v.bounds.size.width/factor, 50)];
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
    if( self.splitViewController && _appearedFirstTime )
    {
        if( ![self.tableView indexPathForSelectedRow] )
        {
            // select first row
            // and do it manualy
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            // make first row selected
            [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            // set filter to rows
            [self filterTorrentListWithFilterOptions:TRStatusOptionsAll];
        }
    }
    else
    {
        [_connector getAllTorrents];
    }
    
    if( _appearedFirstTime )
        [_connector getSessionInfo];
    
    _appearedFirstTime = NO;
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void)stopUpdating
{
    [_refreshTimer invalidate];
    [_connector stopRequests];
    
    _torrentController.refreshControl = nil;
    _torrentController.infoMessage = @"There is no selected server";
}

// main refresh cycle, updates data in detail view controllers
- (void)autorefreshTimerUpdateHandler
{
    [_connector getAllTorrents];
   
    UINavigationController *nav = _torrentController.navigationController;
    
    if( nav.topViewController == _torrentInfoController )
        [_connector getDetailedInfoForTorrentWithId:_torrentInfoController.torrentId];
    
    else if( nav.topViewController == _peerListController)
        [_connector getAllPeersForTorrentWithId:_peerListController.torrentId];
    
    else if( nav.topViewController == _fileListController )
        [_connector getAllFilesForTorrentWithId:_fileListController.torrentId];
    
    else if( _sessionInfo )
    {
        // update free space
        [_connector getFreeSpaceWithDownloadDir:_sessionInfo.downloadDir];
    }
}

- (void)gotFreeSpaceString:(NSString *)freeSpace
{
    NSString *str = [NSString stringWithFormat:@"Free space: %@", freeSpace];
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

- (void)showHeaderDLRate:(NSString*)dlRate ULRate:(NSString*)ulRate
{
    if( !_headerViewDURates )
    {
        _headerViewDURates = [HeaderViewDURates view];
        self.tableView.tableHeaderView = _headerViewDURates;
    }
  
    // fix - hide error message
    if( self.tableView.tableHeaderView != _headerViewDURates )
        self.tableView.tableHeaderView = _headerViewDURates;
    
    _headerViewDURates.uploadString = ulRate;
    _headerViewDURates.downloadString = dlRate;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
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

// should be performed when there is no errors
// occured upon rpc request
- (void)requestToServerSucceeded
{
    [self.refreshControl endRefreshing];
    [_torrentController.refreshControl endRefreshing];
  
    // clear error message    
    //self.headerTitleString = @"Request OK";
}

// got all torrents, refresh statues
// this is a delegate method, performed asychronosly
// from RPCConnector
- (void)gotAllTorrents:(TRInfos *)torrents
{
    [self requestToServerSucceeded];
    
    // update numbers

    [self setCount:torrents.allCount      forCellWithTitle:STATUS_ROW_ALL];
    [self setCount:torrents.activeCount   forCellWithTitle:STATUS_ROW_ACTIVE];
    [self setCount:torrents.checkCount    forCellWithTitle:STATUS_ROW_CHECK];
    [self setCount:torrents.downloadCount forCellWithTitle:STATUS_ROW_DOWNLOAD];
    [self setCount:torrents.seedCount     forCellWithTitle:STATUS_ROW_SEED];
    [self setCount:torrents.stopCount     forCellWithTitle:STATUS_ROW_STOP];
    
    // show torrents in list controller (update)
    // find torrents that are finished downloading
    TRInfos *prev = _torrentController.torrents;
    if( prev )
    {
        NSArray *dtors = prev.downloadingTorrents;
        NSArray *stors = torrents.seedingTorrents;
        
        NSMutableString *sInfo = [NSMutableString string];
        
        for (TRInfo* dt in dtors)
        {
            for( TRInfo* st in stors )
            {
                if( st.trId == dt.trId )
                {
                    // we have found finished torrent need to
                    [sInfo appendString:[NSString stringWithFormat:@"Torrent: %@\n has finished downloading\n", st.name]];
                }
            }
        }
        
        if( sInfo.length > 0 )
        {
            [self showInfoPopup:sInfo];
        }
    } // end of finding finished torrents
    
    _torrentController.torrents = torrents;
    
    NSString *str = [NSString stringWithFormat:@"↑UL:%@ ↓DL:%@",
                              torrents.totalUploadRateString,
                              torrents.totalDownloadRateString];
    
    if( _uploadRateLimitString )
    {
        str = [NSString stringWithFormat:@"%@\n%@",str, _uploadRateLimitString];
    }
    
    if( _downloadRateLimitString )
    {
        str = [NSString stringWithFormat:@"%@\n%@",str, _downloadRateLimitString];
    }
    
    
    [self showHeaderDLRate:torrents.totalDownloadRateString ULRate:torrents.totalUploadRateString];
    
    //self.headerInfoMessage = str;
    //if( !self.splitViewController )
    //_torrentController.headerInfoMessage = str;
    //[self setHeaderUploadRate:torrents.totalUploadRateString andDownloadRate:torrents.totalDownloadRateString];
}

- (void)setCount:(int)count forCellWithTitle:(NSString*)cellTitle
{
    StatusListCell *cell = _cells[cellTitle];
    if( cell )
        cell.numberLabel.text = [NSString stringWithFormat:@"%i", count];
}

// shows alert view for adding torrent by URL (magnet url also)
- (void)showAddTorrentByURLDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add torrent"
                                                    message:@"Type URL or MAGNET URL"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Add torrent", nil];
    
    alert.delegate = self;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)gotTorrentAdded
{
    [self showInfoPopup:@"New torrent was added"];
}

#pragma mark - Alert View delegate methods
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
    _speedLimitController.preferredContentSize = CGSizeMake(190, 400);
    _speedLimitController.selectedSpeed = _selectedDownloadRateIndex;
    _speedLimitController.speedTitles = _speedDownTitles;
    _speedLimitController.delegate = self;
    _speedLimitController.title = @"Speed download limit";
    _speedLimitController.isDownload = YES;
    
    if( self.splitViewController )
    {
        if( _speedPopOver && _speedPopOver.isPopoverVisible )
            [_speedPopOver dismissPopoverAnimated:YES];
        
        _speedPopOver = [[UIPopoverController alloc] initWithContentViewController:_speedLimitController];
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
    _speedLimitController.preferredContentSize = CGSizeMake(190, 400);    
    _speedLimitController.selectedSpeed = _selectedUploadRateIndex;
    _speedLimitController.speedTitles = _speedUpTitles;
    _speedLimitController.delegate = self;
    _speedLimitController.title = @"Speed upload limit";
    _speedLimitController.isDownload = NO;
    
    if( self.splitViewController )
    {
        if( _speedPopOver && _speedPopOver.isPopoverVisible )
            [_speedPopOver dismissPopoverAnimated:YES];
        
        _speedPopOver = [[UIPopoverController alloc] initWithContentViewController:_speedLimitController];
        _speedPopOver.delegate = self;
        [_speedPopOver setPopoverContentSize:CGSizeMake(200, 400)];
        
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
    {
        [_speedPopOver dismissPopoverAnimated:YES];
        _speedPopOver = nil;
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // get the limits!
    if( _speedLimitController.isDownload )
    {
        _selectedDownloadRateIndex = index;
        int rate = [(NSNumber*)_speedDownRates[index] intValue];
        [_connector limitDownloadRateWithSpeed:rate];
    }
    else
    {
        _selectedUploadRateIndex = index;
        int rate = [(NSNumber*)_speedUpRates[index] intValue];
        [_connector limitUploadRateWithSpeed:rate];
    }
    
    _speedLimitController = nil;
}

#pragma mark - Working with session information

// shows SessionConfigController and make request
// for session info
- (void)showSessionConfiguration
{
    // fix
    if( _speedPopOver &&  _speedPopOver.isPopoverVisible )
        [_speedPopOver dismissPopoverAnimated:YES];
    
    _sessionConfigController = instantiateController(CONTROLLER_ID_SESSIONCONFIG);
    _sessionConfigController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                               target:self
                                                                                                               action:@selector(saveSessionParametes)];
    [self.navigationController pushViewController:_sessionConfigController animated:YES];
    
    [_connector getSessionInfo];
    [_connector portTest];
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
    if( !_sessionInfo )
        [_connector getFreeSpaceWithDownloadDir:info.downloadDir];
        
    _sessionInfo = info;
    
    _uploadRateLimitString = nil;
    _downloadRateLimitString = nil;
    
    // update speed information
    if(_sessionInfo.upLimitEnabled )
    {
        _uploadRateLimitString = [NSString stringWithFormat:@"Upload speed limit: %i Kb/s", _sessionInfo.upLimitRate];
        
    }
    
    if( _sessionInfo.downLimitEnabled )
    {
        _downloadRateLimitString = [NSString stringWithFormat:@"Download speed limit: %i Kb/s", _sessionInfo.downLimitRate];
    }
    
    if( _sessionInfo.altLimitEnabled )
    {
        _uploadRateLimitString = [NSString stringWithFormat:@"Alt. speed limits enabled UL:%i KB/s, DL:%i KB/s", _sessionInfo.altUploadRateLimit, _sessionInfo.altDownloadRateLimit];
        _downloadRateLimitString = nil;
    }
    
    if( _sessionConfigController )
        _sessionConfigController.sessionInfo = info;
    
    // show/hide limit icon
    _headerViewDURates.upLimitIsOn = _uploadRateLimitString != nil;
    _headerViewDURates.downLimitIsOn = _downloadRateLimitString != nil;
    
    [self adjustSpeedLimitTables];
}

- (void)gotPortTestedWithSuccess:(BOOL)portIsOpen
{
    if( _sessionConfigController )
        _sessionConfigController.portIsOpen = portIsOpen;
}

- (void)gotSessionSetWithInfo:(TRSessionInfo *)info
{
    [self gotSessionWithInfo:info];
    [self showInfoPopup:@"Settings are saved"];
}

#pragma mark - RPCConnector error hangling

// RPCConnector signals error
- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    // end of refreshing (if it is)
    [self.refreshControl endRefreshing];
    [_torrentController.refreshControl endRefreshing];
    
    if( [requestName isEqualToString:TR_METHODNAME_TORRENTADD] ||
        [requestName isEqualToString:TR_METHODNAME_TORRENTADDURL] )
    {
        [self showErrorPopup:errorMessage];
        return;
    }
    
    
    // show error to background
    //_torrentController.infoMessage = errorMessage;
    _torrentController.torrents = nil;
    _torrentController.errorMessage = errorMessage;
    self.errorMessage = errorMessage;
    
    UINavigationController *nav = _torrentController.navigationController;
    if( _torrentInfoController && nav.visibleViewController == _torrentInfoController )
    {
        [_torrentInfoController showErrorMessage:errorMessage];
    }
}

#pragma mark - TorrentInfoController delegate methods

- (void)stopTorrentWithId:(int)torrentId
{
    //NSLog(@"Stopping torrent");
    
    [_connector stopTorrent:torrentId];
}

- (void)gotTorrentStopedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    [self showInfoPopup:@"Torrent was stopped"];
}

-(void)resumeTorrentWithId:(int)torrentId
{
   // NSLog(@"Resuming torrent");
    
    [_connector resumeTorrent:torrentId];
}

- (void)gotTorrentResumedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    [self showInfoPopup:@"Torrent was resumed"];

}

-(void)verifyTorrentWithId:(int)torrentId
{
     [_connector verifyTorrent:torrentId];
}

- (void)gotTorrentVerifyedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    [self showInfoPopup:@"Torrent is verifying ..."];
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
    [self showInfoPopup:@"Torrent was deleted"];
}

- (void)reannounceTorrentWithId:(int)torrentId
{
    //NSLog(@"Reannouncing torrent");
    [_connector reannounceTorrent:torrentId];
}

- (void)gotTorrentReannouncedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    [self showInfoPopup:@"Torrent is reannouncing ..."];
}

- (void)gotTorrentDetailedInfo:(TRInfo *)torrentInfo
{
    if( _torrentInfoController )
    {
        [_torrentInfoController updateData:torrentInfo];
    }
}

- (void)updateTorrentInfoWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
}

#pragma mark - TorrentListController delegate methods

// shows view controller with detailed info
- (void)showDetailedInfoForTorrentWithId:(int)torrentId
{
    _torrentInfoController = instantiateController( CONTROLLER_ID_TORRENTINFO );
    _torrentInfoController.torrentId = torrentId;
    _torrentInfoController.delegate = self;
    
    // we should make a request to RPCConnector
    // (upon complite, info controller will be updated)
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    
    // and show our controller
    // get nav controller for detail panel
    UINavigationController *nav = _torrentController.navigationController;
    // and push this info controller on top of it
    
    [nav pushViewController:_torrentInfoController animated:YES];
}

#pragma mark - TorrentInfoControllerDelegate

- (void)showPeersForTorrentWithId:(int)torrentId
{
    _peerListController = instantiateController( CONTROLLER_ID_PEERLIST );
    _peerListController.delegate = self;
    _peerListController.torrentId = torrentId;
    _peerListController.title = @"Peers"; //[NSString stringWithFormat:@"Peers: %@", _torrentInfoController.title];
    
    UINavigationController *nav = _torrentController.navigationController;
    [nav pushViewController:_peerListController animated:YES];
    
    [_connector getAllPeersForTorrentWithId:torrentId];
}

- (void)gotAllPeers:(NSArray *)peerInfos forTorrentWithId:(int)torrentId
{
    if( _peerListController )
    {
        _peerListController.peers = peerInfos;
    }
}

- (void)peerListNeedUpdatePeersForTorrentId:(int)torrentId
{
    [_connector getAllPeersForTorrentWithId:torrentId];
}

- (void)showFilesForTorrentWithId:(int)torrentId
{
    _fileListController = instantiateController( CONTROLLER_ID_FILELIST );
    _fileListController.delegate = self;
    _fileListController.torrentId = torrentId;
    _fileListController.title = @"Files";//[NSString stringWithFormat:@"Files: %@", _torrentInfoController.title];
    
    UINavigationController *nav = _torrentController.navigationController;
    [nav pushViewController:_fileListController animated:YES];
    
    [_connector getAllFilesForTorrentWithId:torrentId];
}

- (void)gotAllFiles:(NSArray *)fileInfos forTorrentWithId:(int)torrentId
{
    if( _fileListController )
        _fileListController.fileInfos = fileInfos;
}

- (void)fileListControllerNeedUpdateFilesForTorrentWithId:(int)torrentId
{
    [_connector getAllFilesForTorrentWithId:torrentId];
}

- (void)fileListControllerResumeDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    [_connector resumeDownloadingFilesWithIndexes:indexes forTorrentWithId:torrentId];
}

- (void)fileListControllerStopDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    [_connector stopDownloadingFilesWithIndexes:indexes forTorrentWithId:torrentId];
}

- (void)fileListControllerSetPriority:(int)priority forFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId
{
    [_connector setPriority:priority forFilesWithIndexes:indexes forTorrentWithId:torrentId];
}

// set the filter of TorrentListController
// and fetching all torrents
- (void)filterTorrentListWithFilterOptions:(TRStatusOptions)filterOptions
{
    _torrentController.navigationItem.title = @"Torrents";//self.navigationItem.title;
    _torrentController.popoverButtonTitle = self.title;
    _torrentController.filterOptions = filterOptions;
    
    // on iPhone we should show _torrentController instead of ours
    if( !self.splitViewController )
    {
        [self.navigationController pushViewController:_torrentController animated:YES];
    }
    else
    {
        // on iPad show torrent list
        [_torrentController.navigationController popToRootViewControllerAnimated:YES];
    }
    
    // fetch data for all torrents
    [_connector getAllTorrents];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TRStatusOptions filterOption = [_itemFilterOptions[indexPath.row] unsignedIntValue];
    
    [self filterTorrentListWithFilterOptions: filterOption];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatusListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_STATUSLIST forIndexPath:indexPath];
    
    NSString *title = _itemNames[indexPath.row];
    
    // Configure the cell
    cell.numberLabel.text  = @" ";
    cell.statusLabel.text = title;
    cell.iconImg.image = _itemImages[ indexPath.row ];
    
    // save the cell
    _cells[title] = cell;
    
    return cell;
}

@end
