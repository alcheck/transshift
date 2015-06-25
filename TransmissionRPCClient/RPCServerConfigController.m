//
//  RPCServerConfigController.m
//  TransmissionRPCClient
//
//  UIViewController for RPC server settings
//


#import "RPCServerConfigController.h"
#import "ServerNameCell.h"
#import "ServerHostCell.h"
#import "ServerPortCell.h"
#import "ServerRPCPath.h"
#import "ServerUserNameCell.h"
#import "ServerUserPasswordCell.h"
#import "ServerUseSSLCell.h"
#import "ServerRefreshTimeoutCell.h"
#import "ServerRequestTimeoutCell.h"

// section names
static NSString *SECTION_0_TITLE = @"General";
static NSString *SECTION_1_TITLE = @"RPC settings";
static NSString *SECTION_2_TITLE = @"Security settings";
static NSString *SECTION_3_TITLE = @"Timeout settings";

@interface RPCServerConfigController()

@property(nonatomic) NSArray  *sections;
@property(nonatomic) NSDictionary *cells;
@property(nonatomic) NSString *serverName;
@property(nonatomic) NSString *serverHost;
@property(nonatomic) NSString *serverRPCPath;
@property(nonatomic) NSString *userName;
@property(nonatomic) NSString *userPassword;
@property(nonatomic) BOOL      useSSL;
@property(nonatomic) int       refreshTimeout;
@property(nonatomic) int       requestTimeout;
@property(nonatomic) int       serverPort;

@end


@implementation RPCServerConfigController


- (void)viewDidLoad
{
    [self initCellsAndSections];
    [self loadConfig];
}

// show/hide error message error message
- (void)showErrorMessage: (NSString *)msg
{
    // tableview header
    UILabel *headerView = [[UILabel  alloc] initWithFrame:CGRectZero];
    headerView.text = msg;
    headerView.backgroundColor = [UIColor redColor];
    headerView.textColor = [UIColor whiteColor];
    headerView.numberOfLines = 0;
    headerView.font = [UIFont systemFontOfSize:15];
    headerView.textAlignment = NSTextAlignmentCenter;
    [headerView sizeToFit];
    
    CGRect r = self.tableView.bounds;
    r.size.height = headerView.bounds.size.height + 40;
    
    headerView.bounds = r;
    
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = headerView;
    [self.tableView endUpdates];
}

- (void)hideErrorMessage
{
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = nil;
    [self.tableView endUpdates];
}

#pragma mark - Reading/Writing field properties

// get/set server name
- (NSString *)serverName
{
    ServerNameCell *cell = self.cells[CELL_ID_SERVER_NAME];
    return [cell.serverName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (void)setServerName:(NSString *)serverName
{
    ServerNameCell *cell = self.cells[CELL_ID_SERVER_NAME];
    cell.serverName.text = serverName;
}

// get/set server host
- (NSString *)serverHost
{
    ServerHostCell *cell = self.cells[CELL_ID_SERVER_HOST];
    return [cell.hostName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (void)setServerHost:(NSString *)serverHost
{
    ServerHostCell *cell = self.cells[CELL_ID_SERVER_HOST];
    cell.hostName.text = serverHost;
}

// get/set server RPC path
- (NSString *)serverRPCPath
{
    ServerRPCPathCell *cell = self.cells[CELL_ID_RPCPATH_CELL];
    return [cell.path.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (void)setServerRPCPath:(NSString *)serverRPCPath
{
    ServerRPCPathCell *cell = self.cells[CELL_ID_RPCPATH_CELL];
    cell.path.text = serverRPCPath;
}

// get/set user name
- (NSString *)userName
{
    ServerUserNameCell *cell = self.cells[CELL_ID_USERNAME];
    return [cell.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (void)setUserName:(NSString *)userName
{
    ServerUserNameCell *cell = self.cells[CELL_ID_USERNAME];
    cell.userName.text = userName;
}

// get/set user password
- (NSString *)userPassword
{
    ServerUserPasswordCell *cell = self.cells[CELL_ID_USERPASSWORD];
    return cell.userPassword.text;
}
- (void)setUserPassword:(NSString *)userPassword
{
    ServerUserPasswordCell *cell = self.cells[CELL_ID_USERPASSWORD];
    cell.userPassword.text = userPassword;
}

// get/set use SSL flag
- (BOOL)useSSL
{
    ServerUseSSLCell *cell = self.cells[CELL_ID_USESSL];
    return cell.status;
}
- (void)setUseSSL:(BOOL)useSSL
{
    ServerUseSSLCell *cell = self.cells[CELL_ID_USESSL];
    cell.status = useSSL;
}

// get/set refresh timeout
- (int)refreshTimeout
{
    ServerRefreshTimeoutCell *cell = self.cells[CELL_ID_REFRESHTIMEOUT];
    return cell.timeoutValue;
}
- (void)setRefreshTimeout:(int)refreshTimeout
{
    ServerRefreshTimeoutCell *cell = self.cells[CELL_ID_REFRESHTIMEOUT];
    cell.timeoutValue = refreshTimeout;
}

// get/set request timeout
- (int)requestTimeout
{
    ServerRequestTimeoutCell *cell = self.cells[CELL_ID_REQUESTTIMEOUT];
    return cell.timeoutValue;
}
- (void)setRequestTimeout:(int)timeout
{
    ServerRequestTimeoutCell *cell = self.cells[CELL_ID_REQUESTTIMEOUT];
    cell.timeoutValue = timeout;
}

// get/set server port
- (int)serverPort
{
    ServerPortCell *cell = self.cells[CELL_ID_SERVER_PORT];
    return [cell.portField.text intValue];
}
- (void)setServerPort:(int)serverPort
{
    ServerPortCell *cell = self.cells[CELL_ID_SERVER_PORT];
    cell.portField.text = [NSString stringWithFormat:@"%i", serverPort];
}


#pragma mark - utility methods

// update values from config
- (void)loadConfig
{
   // NSLog(@"Loading config: %@, sectons = %@", self.config, _sections);
    
   // loading values
   if( self.config )
   {
       self.serverName = self.config.name;
       self.serverHost = self.config.host;
       self.serverPort = self.config.port;
       self.serverRPCPath = self.config.rpcPath;
       self.userName = self.config.userName;
       self.userPassword = self.config.userPassword;
       self.useSSL = self.config.useSSL;
       self.refreshTimeout = self.config.refreshTimeout;
       self.requestTimeout = self.config.requestTimeout;
   }
}

- (BOOL)saveConfig
{
    UIColor *errColor = [UIColor redColor];
    UIColor *normalColor = [UIColor blackColor];
    
    if( !self.config )
        self.config = [[RPCServerConfig alloc] init];
    
    // saving values
    ServerNameCell *cell = self.cells[CELL_ID_SERVER_NAME];
    if( self.serverName.length < 1 )
    {
        [self showErrorMessage:@"You should enter server NAME"];
        cell.label.textColor = errColor;
        [cell.serverName becomeFirstResponder];
        return NO;
    }
    cell.label.textColor = normalColor;
    
    ServerHostCell *hostCell = self.cells[CELL_ID_SERVER_HOST];
    if( self.serverHost.length < 1 )
    {
        [self showErrorMessage:@"You should enter server HOST name"];
        hostCell.label.textColor = errColor;
        [hostCell.hostName becomeFirstResponder];
        return NO;
    }
    hostCell.label.textColor = normalColor;
    
    ServerPortCell *portCell = self.cells[CELL_ID_SERVER_PORT];
    if( !(self.serverPort > 0 && self.serverPort < 655356) )
    {
        [self showErrorMessage:@"Server port must be in range from 0 to 65536. By default server port number is 8090"];
        portCell.label.textColor = errColor;
        [portCell.portField becomeFirstResponder];
        return NO;
    }
    portCell.label.textColor = normalColor;
    
    ServerRPCPathCell *pathCell = self.cells[CELL_ID_RPCPATH_CELL];
    if( self.serverRPCPath.length < 1 )
    {
        [self showErrorMessage:@"You should enter server RPC path. By default server rpc path is /transmission/rpc"];
        pathCell.label.textColor = errColor;
        [pathCell.path becomeFirstResponder];
        return NO;
    }
    pathCell.label.textColor = normalColor;

    // when all values is ok, save config
    self.config.port = self.serverPort;
    self.config.host = self.serverHost;
    self.config.name = self.serverName;
    self.config.rpcPath = self.serverRPCPath;
    self.config.userName = self.userName;
    self.config.userPassword = self.userPassword;
    self.config.useSSL = self.useSSL;
    self.config.refreshTimeout = self.refreshTimeout;
    self.config.requestTimeout = self.requestTimeout;
    
    [self hideErrorMessage];
    
    //NSLog(@"RPC server config saved successfuly: %@", self.config);
    return YES;
}

// return array of sections
-(NSArray*)sections
{
    if( !_sections || !_cells )
    {
        [self initCellsAndSections];
    }
    
    return _sections;
}

- (void)initCellsAndSections
{
    // init array with section titles and cell's ids int these sections
    _sections =  @[ @[ SECTION_0_TITLE,  @[CELL_ID_SERVER_NAME] ],
                    @[ SECTION_1_TITLE,  @[CELL_ID_SERVER_HOST, CELL_ID_SERVER_PORT, CELL_ID_RPCPATH_CELL] ],
                    @[ SECTION_2_TITLE,  @[CELL_ID_USERNAME, CELL_ID_USERPASSWORD, CELL_ID_USESSL] ],
                    @[ SECTION_3_TITLE,  @[CELL_ID_REFRESHTIMEOUT, CELL_ID_REQUESTTIMEOUT] ]
                    ];
    // init dict with cellids and actual cell's instances
    _cells = @{
               CELL_ID_SERVER_NAME : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_SERVER_NAME],
               CELL_ID_SERVER_HOST : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_SERVER_HOST],
               CELL_ID_RPCPATH_CELL : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_RPCPATH_CELL],
               CELL_ID_SERVER_PORT : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_SERVER_PORT],
               CELL_ID_USERNAME : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_USERNAME],
               CELL_ID_USERPASSWORD : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_USERPASSWORD],
               CELL_ID_USESSL : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_USESSL],
               CELL_ID_REFRESHTIMEOUT : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_REFRESHTIMEOUT],
               CELL_ID_REQUESTTIMEOUT : [self.tableView dequeueReusableCellWithIdentifier:CELL_ID_REQUESTTIMEOUT]
               };

}

#pragma mark - Table view data source

// section 1 - server name, host, port and rpc path
// section 2 - user name, user password and ssl flag
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section][0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sec = self.sections[section];
    NSArray *secIds = sec[1];
    
    return  secIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section = self.sections[indexPath.section];
    NSArray *ids = section[1];

    return self.cells[ ids[indexPath.row] ];
}



@end
