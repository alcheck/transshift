//
//  StatusListController.m
//  TransmissionRPCClient
//
//  Shows torrents statueses
//

#import "StatusListController.h"
#import "TorrentListController.h"
#import "TorrentInfoController.h"
#import "RPCConnector.h"

#define STATUS_SECTION_TITILE       @"Torrents"


@interface StatusListController () <RPCConnectorDelegate, TorrentListControllerDelegate, UISplitViewControllerDelegate>

// statistics
@property(nonatomic) NSUInteger countAll;
@property(nonatomic) NSUInteger countStop;
@property(nonatomic) NSUInteger countDownload;
@property(nonatomic) NSUInteger countSeed;

@end

@implementation StatusListController

{
    NSArray *_sections;
    NSArray *_itemNames;
    NSMutableDictionary *_cells;
    RPCConnector *_connector;
    
    NSTimer *_refreshTimer;
    
    TorrentListController *_torrentController;          // holds detail torrent list controller
    TorrentInfoController *_torrentInfoController;      // holds torrent info controller (when torrent is selected from torrent list)
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNames];
    
    if( self.config )
    {
        self.navigationItem.title = self.config.name;
        _connector = [[RPCConnector alloc] initWithConfig:self.config andDelegate:self];
        
        // config pull-to refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
        
        if( self.config.refreshTimeout > 0 )
        {
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.config.refreshTimeout target:self
                                                           selector:@selector(updateData) userInfo:nil repeats:YES];
        }
    }
    
    // getting detail controller - TorrentListController
    // on iPad it is already created on start
    // on iPhone it should be created from storyboard
    if( self.splitViewController )
    {
        // left (detail) controller should be NavigationContoller with our TorrentListController
        UINavigationController *rightNav = self.splitViewController.viewControllers[1];
        _torrentController = rightNav.viewControllers[0];
        // clear all current torrents
        _torrentController.torrents = nil;
    }
    else
    {
        // on iPhone instantiate this controller
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
        _torrentController = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_TORRENTLIST];
    }
    
    // set us as delegate
    _torrentController.delegate = self;
    
    // Configure refresh control for torrent
    _torrentController.refreshControl = [[UIRefreshControl alloc] init];
    [_torrentController.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if there is a leftbutton on _torrentConroller -> change title
    if( _torrentController.navigationItem.leftBarButtonItem )
    {
        _torrentController.popoverButtonTitle = self.navigationItem.title;
        _torrentController.navigationItem.leftBarButtonItem.title = self.navigationItem.title;
    }
    
    // **** ***** UPDATE DATA ****
    [_connector getAllTorrents];
}

- (void)initNames
{
    _sections = @[ STATUS_SECTION_TITILE ];
    _itemNames = @[ STATUS_ROW_ALL, STATUS_ROW_DOWNLOAD, STATUS_ROW_SEED, STATUS_ROW_STOP ];
    _cells = [NSMutableDictionary dictionary];
}

- (void)stopUpdating
{
    [_refreshTimer invalidate];
    [_connector stopRequests];
    _torrentController.refreshControl = nil;
    _torrentController.backgroundTitle = @"There is no selected server";
}

- (void)updateData
{
    [_connector getAllTorrents];
    
    if( _torrentInfoController )
    {
        UINavigationController *nav = _torrentController.navigationController;
        if( nav.visibleViewController == _torrentInfoController )
            [_connector getDetailedInfoForTorrentWithId:_torrentInfoController.torrentId];
    }
}

// should be performed when there is no errors
// occured upon rpc request
- (void)requestToServerSucceeded
{
    [self.refreshControl endRefreshing];
    [_torrentController.refreshControl endRefreshing];
    
    // clear error message
    self.tableView.tableHeaderView = nil;
}

// got all torrents, refresh statues
// this is a delegate method, performed asychronosly
// from RPCConnector
- (void)gotAllTorrents:(TRInfos *)torrents
{
    [self requestToServerSucceeded];
    
    // update numbers
    self.countAll = torrents.allCount;
    self.countStop = torrents.stopCount;
    self.countDownload = torrents.downloadCount;
    self.countSeed = torrents.seedCount;
   
    // show torrents in list controller (update)
    _torrentController.torrents = torrents;
}

// update count in rows
- (void)setCountAll:(NSUInteger)countAll
{
    UITableViewCell *cell = _cells[STATUS_ROW_ALL];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)countAll];
    [cell setNeedsLayout];
}

- (void)setCountStop:(NSUInteger)countStop
{
    UITableViewCell *cell = _cells[STATUS_ROW_STOP];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)countStop];
    [cell setNeedsLayout];

}

- (void)setCountDownload:(NSUInteger)countDownload
{
    UITableViewCell *cell = _cells[STATUS_ROW_DOWNLOAD];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)countDownload];
    [cell setNeedsLayout];

}

- (void)setCountSeed:(NSUInteger)countSeed
{
    UITableViewCell *cell = _cells[STATUS_ROW_SEED];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)countSeed];
    [cell setNeedsLayout];
}

#pragma mark - RPCConnector error hangling

// RPCConnector signals error
- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    [self.refreshControl endRefreshing];
    [_torrentController.refreshControl endRefreshing];
    _torrentController.backgroundTitle = errorMessage;
    [self showErrorMessage:errorMessage];
}

- (void)showErrorMessage:(NSString*)message
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor redColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 10;
    label.text = message;
    [label sizeToFit];
    
    CGRect r = self.tableView.bounds;
    r.size.height = label.bounds.size.height + 40;
    
    label.bounds = r;
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = label;
    [self.tableView endUpdates];
}

#pragma mark - TorrentListController delegate methods

// shows view controller with detailed info
- (void)showDetailedInfoForTorrentWithId:(int)torrentId
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
    _torrentInfoController = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_TORRENTINFO];
    _torrentInfoController.torrentId = torrentId;
    
    // we should make a request to RPCConnector
    // (upon complite, info controller will be updated)
    [_connector getDetailedInfoForTorrentWithId:torrentId];
    
    // and show our controller
    // get nav controller for detail panel
    UINavigationController *nav = _torrentController.navigationController;
    // and push this info controller on top of it
    
    [nav pushViewController:_torrentInfoController animated:YES];
}

- (void)gotTorrentDetailedInfo:(TRInfo *)torrentInfo
{
    if( _torrentInfoController )
    {
        [_torrentInfoController updateData:torrentInfo];
    }
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_connector getAllTorrents];

    _torrentController.navigationItem.title = self.navigationItem.title;
    
    switch (indexPath.row) {
        case 0:
            _torrentController.filterOptions = TRStatusOptionsAll;
            break;
            
        case 1:
            _torrentController.filterOptions = TRStatusOptionsDownload;
            break;
            
        case 2:
            _torrentController.filterOptions = TRStatusOptionsSeed;
            break;
    
        case 3:
            _torrentController.filterOptions = TRStatusOptionsStop;
            break;
            
        case 4:
            _torrentController.filterOptions = TRStatusOptionsCheck;
            break;
            
        default:
            break;
    }
    
    
    if( !self.splitViewController )
    {
        [self.navigationController pushViewController:_torrentController animated:YES];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TORRENTSTATUS forIndexPath:indexPath];
    
    NSString *title = _itemNames[indexPath.row];
    
    // Configure the cell
    cell.detailTextLabel.text  = @"";
    cell.textLabel.text = title;
    
    // save the cell
    _cells[title] = cell;
    
    return cell;
}

@end
