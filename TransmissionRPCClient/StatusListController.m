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
#import "RPCConnector.h"

#define STATUS_SECTION_TITILE       @"Torrents"


@interface StatusListController () <RPCConnectorDelegate,
                                    TorrentListControllerDelegate,
                                    TorrentInfoControllerDelegate,
                                    PeerListControllerDelegate,
                                    FileListControllerDelegate,
                                    UISplitViewControllerDelegate>

@end

@implementation StatusListController

{
    NSArray *_sections;
    NSArray *_itemNames;
    NSArray *_itemFilterOptions;
    NSArray *_itemImages;
    
    NSMutableDictionary *_cells;
    
    RPCConnector *_connector;
    
    NSTimer *_refreshTimer;                             // holds main autorefresh timer
    
    TorrentListController *_torrentController;          // holds detail torrent list controller
    TorrentInfoController *_torrentInfoController;      // holds torrent info controller (when torrent is selected from torrent list)
    PeerListController    *_peerListController;         // holds controller for showing peers
    FileListController    *_fileListController;         // holds controller for showing files
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize section name and section row names
    [self initNames];
    
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


- (void)viewDidAppear:(BOOL)animated
{
    static BOOL bFirstTime = YES;
    
    [super viewDidAppear:animated];
    
    // if there is a leftbutton on _torrentConroller -> change title
    if( self.splitViewController )
    {
        _torrentController.popoverButtonTitle = self.title;
    }
    
    // check if it is ipad we shoud and none of rows is selected - select all row (0)
    if( self.splitViewController && bFirstTime )
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
    
    bFirstTime = NO;
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
   
    //if( _torrentInfoController )
    {
        UINavigationController *nav = _torrentController.navigationController;
        
        if( nav.topViewController == _torrentInfoController )
            [_connector getDetailedInfoForTorrentWithId:_torrentInfoController.torrentId];
        else if( nav.topViewController == _peerListController)
            [_connector getAllPeersForTorrentWithId:_peerListController.torrentId];
        else if( nav.topViewController == _fileListController )
            [_connector getAllFilesForTorrentWithId:_fileListController.torrentId];
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
    _torrentController.torrents = torrents;
    
    self.headerInfoMessage = [NSString stringWithFormat:@"↑UL:%@ ↓DL:%@",
                              torrents.totalUploadRateString,
                              torrents.totalDownloadRateString];
    //[self setHeaderUploadRate:torrents.totalUploadRateString andDownloadRate:torrents.totalDownloadRateString];
}

- (void)setCount:(int)count forCellWithTitle:(NSString*)cellTitle
{
    StatusListCell *cell = _cells[cellTitle];
    if( cell )
        cell.numberLabel.text = [NSString stringWithFormat:@"%i", count];
}


#pragma mark - RPCConnector error hangling

// RPCConnector signals error
- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    // end of refreshing (if it is)
    [self.refreshControl endRefreshing];
    [_torrentController.refreshControl endRefreshing];
    
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
}

-(void)resumeTorrentWithId:(int)torrentId
{
   // NSLog(@"Resuming torrent");
    
    [_connector resumeTorrent:torrentId];
}

- (void)gotTorrentResumedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
}

-(void)verifyTorrentWithId:(int)torrentId
{
    //NSLog(@"Verifying torrent");
    
    [_connector verifyTorrent:torrentId];
}

- (void)gotTorrentVerifyedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
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
}

- (void)reannounceTorrentWithId:(int)torrentId
{
    //NSLog(@"Reannouncing torrent");
    [_connector reannounceTorrent:torrentId];
}

- (void)gotTorrentReannouncedWithId:(int)torrentId
{
    [_connector getDetailedInfoForTorrentWithId:torrentId];
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
