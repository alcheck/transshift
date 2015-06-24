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
static NSString *SECTION_0_TITLE = @"Server name";
static NSString *SECTION_1_TITLE = @"Remote RPC server settings";
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
    
    self.title = @"Add new server";
}


- (void)viewDidAppear:(BOOL)animated
{
    // load config if needed
    if (self.config)
    {
        [self loadConfig];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // save config
    [self saveConfig];
}

#pragma mark - Reading/Writing field properties

// get/set server name
- (NSString *)serverName
{
    ServerNameCell *cell = [self cellForId:CELL_ID_SERVER_NAME];
    return cell.serverName.text;
}
- (void)setServerName:(NSString *)serverName
{
    ServerNameCell *cell = [self cellForId:CELL_ID_SERVER_NAME];
    cell.serverName.text = serverName;
}

// get/set server host
- (NSString *)serverHost
{
    ServerHostCell *cell = [self cellForId:CELL_ID_SERVER_HOST];
    return cell.hostName.text;
}
- (void)setServerHost:(NSString *)serverHost
{
    ServerHostCell *cell = [self cellForId:CELL_ID_SERVER_HOST];
    cell.hostName.text = serverHost;
}

// get/set server RPC path
- (NSString *)serverRPCPath
{
    ServerRPCPathCell *cell = [self cellForId:CELL_ID_RPCPATH_CELL];
    return cell.path.text;
}
- (void)setServerRPCPath:(NSString *)serverRPCPath
{
    ServerRPCPathCell *cell = [self cellForId:CELL_ID_RPCPATH_CELL];
    cell.path.text = serverRPCPath;
}

// get/set user name
- (NSString *)userName
{
    ServerUserNameCell *cell = [self cellForId:CELL_ID_USERNAME];
    return cell.userName.text;
}
- (void)setUserName:(NSString *)userName
{
    ServerUserNameCell *cell = [self cellForId:CELL_ID_USERNAME];
    cell.userName.text = userName;
}

// get/set user password
- (NSString *)userPassword
{
    ServerUserPasswordCell *cell = [self cellForId:CELL_ID_USERPASSWORD];
    return cell.userPassword.text;
}
- (void)setUserPassword:(NSString *)userPassword
{
    ServerUserPasswordCell *cell = [self cellForId:CELL_ID_USERPASSWORD];
    cell.userPassword.text = userPassword;
}

// get/set use SSL flag
- (BOOL)useSSL
{
    ServerUseSSLCell *cell = [self cellForId:CELL_ID_USESSL];
    return cell.statusSwitch.on;
}
- (void)setUseSSL:(BOOL)useSSL
{
    ServerUseSSLCell *cell = [self cellForId:CELL_ID_USESSL];
    cell.statusSwitch.on = useSSL;
}

// get/set refresh timeout
- (int)refreshTimeout
{
    ServerRefreshTimeoutCell *cell = [self cellForId:CELL_ID_REFRESHTIMEOUT];
    return cell.timeoutValue;
}
- (void)setRefreshTimeout:(int)refreshTimeout
{
    ServerRefreshTimeoutCell *cell = [self cellForId:CELL_ID_REFRESHTIMEOUT];
    cell.timeoutValue = refreshTimeout;
}

// get/set request timeout
- (int)requestTimeout
{
    ServerRequestTimeoutCell *cell = [self cellForId:CELL_ID_REQUESTTIMEOUT];
    return cell.timeoutValue;
}
- (void)setRequestTimeout:(int)timeout
{
    ServerRequestTimeoutCell *cell = [self cellForId:CELL_ID_REQUESTTIMEOUT];
    cell.timeoutValue = timeout;
}

// get/set server port
- (int)serverPort
{
    ServerPortCell *cell = [self cellForId:CELL_ID_SERVER_PORT];
    return [cell.portField.text intValue];
}
- (void)setServerPort:(int)serverPort
{
    ServerPortCell *cell = [self cellForId:CELL_ID_SERVER_PORT];
    cell.portField.text = [NSString stringWithFormat:@"%i", serverPort];
}


#pragma mark - utility methods

// update values from config
- (void)loadConfig
{
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

- (void)saveConfig
{
    if( !self.config )
        self.config = [[RPCServerConfig alloc] init];
    
    // saving values
    self.config.name = self.serverName;
    self.config.host = self.serverHost;
    self.config.port = self.serverPort;
    self.config.rpcPath = self.serverRPCPath;
    self.config.userName = self.userName;
    self.config.userPassword = self.userPassword;
    self.config.useSSL = self.useSSL;
    self.config.refreshTimeout = self.refreshTimeout;
    self.config.requestTimeout = self.requestTimeout;
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

// returns cell for cell id
- (id)cellForId:(NSString*)cellId
{
//    for( int i = 0; i < self.sections.count; i++ )
//    {
//        NSArray *arr = self.sections[i];
//        NSArray *cellIds = arr[1];
//        
//        for( int j = 0; j < cellIds.count; i++ )
//        {
//            if( [cellId isEqualToString:cellIds[j]] )
//            {
//                NSIndexPath *path = [NSIndexPath indexPathForRow:j inSection:i];
//               return [self.tableView cellForRowAtIndexPath:path];
//            }
//        }
//    }
//    
//    NSLog(@"cellForId returned nil for Id: %@", cellId);
//    return nil;
    return self.cells[cellId];
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
    //
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
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ids[indexPath.row] forIndexPath:indexPath];
    
    //return cell;
    return self.cells[ ids[indexPath.row] ];
}



@end
