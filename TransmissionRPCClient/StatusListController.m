//
//  StatusListController.m
//  TransmissionRPCClient
//
//  Shows torrents statueses
//

#import "StatusListController.h"
#import "TorrentListController.h"
#import "RPCConnector.h"

#define STATUS_SECTION_TITILE   @"Torrents"
#define STATUS_ROW_ALL          @"All"
#define STATUS_ROW_DOWNLOAD     @"Downloading"
#define STATUS_ROW_SEED         @"Seeding"
#define STATUS_ROW_STOP         @"Stopped"

@interface StatusListController () <RPCConnectorDelegate, UISplitViewControllerDelegate>
@end

@implementation StatusListController

{
    NSArray *_sections;
    NSArray *_itemNames;
    NSMutableDictionary *_cells;
    RPCConnector *_connector;
    
    NSTimer *_refreshTimer;
    
    TorrentListController *_torrentController;
    
    // statistics
    int countAll;
    int countStop;
    int countDownload;
    int countSeed;
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
        [self.refreshControl addTarget:self action:@selector(getAllTorrents) forControlEvents:UIControlEventValueChanged];
        
        if( self.config.refreshTimeout > 0 )
        {
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.config.refreshTimeout target:self
                                                           selector:@selector(getAllTorrents) userInfo:nil repeats:YES];
        }
    }
    
    if( self.splitViewController )
    {
        UINavigationController *rightNav = self.splitViewController.viewControllers[1];
        //rightNav.viewControllers = @[_torrentController];
        _torrentController = rightNav.viewControllers[0];
        
        self.splitViewController.delegate = self;
    }
    else
    {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"controllers" bundle:nil];
        _torrentController = [board instantiateViewControllerWithIdentifier:CONTROLLER_ID_TORRENTLIST];
    }
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.config.name;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if( self.navigationItem.leftBarButtonItem == barButtonItem )
        self.navigationItem.leftBarButtonItem = nil;
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
}

// perform async request of all torrents
- (void)getAllTorrents
{
    [_connector getAllTorrents];
}

//
- (void)requestToServerSucceeded
{
    [self.refreshControl endRefreshing];
    self.tableView.tableHeaderView = nil;
}

// got all torrents, refresh statues
- (void)gotAllTorrents:(NSArray *)torrents
{
    [self requestToServerSucceeded];
    
    countAll = torrents.count;
    countStop = 0;
    countDownload = 0;
    countSeed = 0;
    
    for( NSDictionary* trInfo in torrents)
    {
        int status = [(NSString*)trInfo[@"status"] intValue];
        if( status == TR_STATUS_CHECK ||
            status == TR_STATUS_CHECK_WAIT ||
            status == TR_STATUS_DOWNLOAD ||
            status == TR_STATUS_DOWNLOAD_WAIT )
            countDownload++;
        else if (status == TR_STATUS_SEED || status == TR_STATUS_SEED_WAIT)
            countSeed++;
        else if (status == TR_STATUS_STOPPED)
            countStop++;
    }
    
    [self updateStatusNumbers];
    
    NSDate *date = [NSDate date];
    _torrentController.backgroundTitle = [NSString stringWithFormat:@"Last updated at %@", date];
}

- (void)updateStatusNumbers
{
    UITableViewCell *cell;
    
    //[self.tableView beginUpdates];
    // all
    cell = _cells[STATUS_ROW_ALL];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", countAll];
    [cell setNeedsLayout];

    // downloading
    cell = _cells[STATUS_ROW_DOWNLOAD];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", countDownload];
    [cell setNeedsLayout];

    // seeding
    cell = _cells[STATUS_ROW_SEED];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", countSeed];
    [cell setNeedsLayout];

    // stopped
    cell = _cells[STATUS_ROW_STOP];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", countStop];
    [cell setNeedsLayout];
    
    //[self.tableView endUpdates];
}

- (void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage
{
    [self.refreshControl endRefreshing];
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
    r.size.height = label.bounds.size.height + 30;
    
    label.bounds = r;
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = label;
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = _itemNames[indexPath.row];
    _torrentController.navigationItem.title = title;
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"torrentStatusCell" forIndexPath:indexPath];
    
    NSString *title = _itemNames[indexPath.row];
    
    // Configure the cell
    cell.detailTextLabel.text  = @"";
    cell.textLabel.text = title;
    
    _cells[title] = cell;
    
    return cell;
}

@end
