//
//  RPCServerConfigController.m
//  TransmissionRPCClient
//
//  UIViewController for RPC server settings
//


#import "RPCServerConfigController.h"
#import "GlobalConsts.h"

@interface RPCServerConfigController()

// TABLE VIEW CONFIG CONTROLS

// GENERAL SETTINGS
@property (weak, nonatomic) IBOutlet UIImageView *iconServerName;
@property (weak, nonatomic) IBOutlet UILabel *labelServerName;
@property (weak, nonatomic) IBOutlet UITextField *textServerName;

// RPC SETTINGS
@property (weak, nonatomic) IBOutlet UIImageView *iconHost;
@property (weak, nonatomic) IBOutlet UILabel *labelHost;
@property (weak, nonatomic) IBOutlet UITextField *textHost;

@property (weak, nonatomic) IBOutlet UIImageView *iconPort;
@property (weak, nonatomic) IBOutlet UILabel *labelPort;
@property (weak, nonatomic) IBOutlet UITextField *textPort;

@property (weak, nonatomic) IBOutlet UIImageView *iconRPCPath;
@property (weak, nonatomic) IBOutlet UILabel *labelRPCPath;
@property (weak, nonatomic) IBOutlet UITextField *textRPCPath;

// SECURITY SETTINGS
@property (weak, nonatomic) IBOutlet UIImageView *iconUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UITextField *textUserName;

@property (weak, nonatomic) IBOutlet UIImageView *iconUserPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelUserPassword;
@property (weak, nonatomic) IBOutlet UITextField *textUserPassword;

@property (weak, nonatomic) IBOutlet UIImageView *iconUseSSL;
@property (weak, nonatomic) IBOutlet UILabel *labelUseSSL;
@property (weak, nonatomic) IBOutlet UISwitch *switchUseSSL;


// TIMEOUT SETTINGS
@property (weak, nonatomic) IBOutlet UIImageView *iconRefreshTimeout;
@property (weak, nonatomic) IBOutlet UILabel *labelRefreshTimeout;
@property (weak, nonatomic) IBOutlet UILabel *labelRefreshTimeoutNumber;
@property (weak, nonatomic) IBOutlet UIStepper *stepperRefreshTimeout;


@property (weak, nonatomic) IBOutlet UIImageView *iconRequestTimeout;
@property (weak, nonatomic) IBOutlet UILabel *labelRequestTimeout;
@property (weak, nonatomic) IBOutlet UILabel *labelRequestTimeoutNumber;
@property (weak, nonatomic) IBOutlet UIStepper *stepperRequestTimeout;

// MISC
@property (weak, nonatomic) IBOutlet UISwitch *switchShowFreeSpace;
@property (weak, nonatomic) IBOutlet UIImageView *iconShowFreeSpace;


@end


@implementation RPCServerConfigController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIcons];
    [self loadConfig];
}

- (void)initIcons
{
    NSArray *arr = @[self.iconServerName,
                     self.iconHost,
                     self.iconPort,
                     self.iconRPCPath,
                     self.iconUserName,
                     self.iconUserPassword,
                     self.iconUseSSL,
                     self.iconRefreshTimeout,
                     self.iconRequestTimeout,
                     self.iconShowFreeSpace ];
    
    
    for (UIImageView *iv in arr)
        iv.image = [iv.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


- (NSString*)trimString:(NSString*)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - utility methods

// update values from config
- (void)loadConfig
{
   // NSLog(@"Loading config: %@, sectons = %@", self.config, _sections);
    
   // loading values
   if( self.config )
   {
       self.textServerName.text = self.config.name;
       
       self.textHost.text = self.config.host;
       self.textPort.text = [NSString stringWithFormat:@"%u", self.config.port];
       self.textRPCPath.text = self.config.rpcPath;
       
       self.textUserName.text = self.config.userName;
       self.textUserPassword.text = self.config.userPassword;
       self.switchUseSSL.on = self.config.useSSL;
       
       self.stepperRefreshTimeout.value = self.config.refreshTimeout;
       self.stepperRequestTimeout.value = self.config.requestTimeout;
       
       self.switchShowFreeSpace.on = self.config.showFreeSpace;
   }
    
    [_stepperRefreshTimeout sendActionsForControlEvents:UIControlEventValueChanged];
    [_stepperRequestTimeout sendActionsForControlEvents:UIControlEventValueChanged];    
}

- (void) showRowError:(NSString*)errorMessage icon:(UIImageView*)iconImg label:(UILabel*)label textControl:(UITextField*)textControl
{
    UIColor *errColor = [UIColor redColor];
    UIColor *normalColor = [UIColor blackColor];

    if( errorMessage )
    {
        //self.errorMessage = errorMessage;
        label.textColor = errColor;
        iconImg.tintColor = errColor;
        
        if( textControl )
            [textControl becomeFirstResponder];
    }
    else
    {
        label.textColor = normalColor;
        iconImg.tintColor = self.tableView.tintColor;
    }
}

- (BOOL)saveConfig
{
    // if server config is not
    // set, it means that we create new serve config
    // and should return this config
    if( !self.config )
        self.config = [[RPCServerConfig alloc] init];
    
    NSMutableString *errString = [NSMutableString string];
    BOOL success = YES;
    
    NSString *serverName;
    NSString *host;
    NSString *rpcPath;
    
    NSString *str = [self trimString: self.textServerName.text ];
    
    if( str.length < 1 )
    {
        [errString appendString: NSLocalizedString(@"You should enter server NAME\n", @"RPCServerConfig error message")];
        [self showRowError:errString
                      icon:self.iconServerName
                     label:self.labelServerName
               textControl:self.textServerName ];
        
        success = NO;
    }
    else
    {
        [self showRowError:nil icon:self.iconServerName label:self.labelServerName textControl:nil ];
         serverName = str;
    }
    
    str = [self trimString: self.textHost.text ];
    if( str.length < 1 )
    {
        [errString appendString: NSLocalizedString(@"You should enter server HOST name\n", @"RPCServerConfig error message")];
        [self showRowError:errString
                      icon:self.iconHost
                     label:self.labelHost
               textControl:self.textHost ];
        
        success = NO;
    }
    else
    {
        [self showRowError:nil icon:self.iconHost label:self.labelHost textControl:nil];
        host = str;
    }
    
   
    int port = [[self trimString:self.textPort.text] intValue];
    
    if( port <= 0 || port > 65535 )
    {
        [errString appendString: NSLocalizedString(@"Server port must be in range from 0 to 65535. By default server port number is 8090\n", @"RPCServerConfig error message")];
        [self showRowError: errString
                      icon:self.iconPort
                     label:self.labelPort
               textControl:self.textPort];
        success = NO;
    }
    else
    {
        [self showRowError:nil icon:self.iconPort label:self.labelPort textControl:nil];
    }
    
    str = [self trimString: self.textRPCPath.text];
    if( str.length < 1 )
    {
        [errString appendString: NSLocalizedString(@"You should enter server RPC path. By default server rpc path is /transmission/rpc", @"RPCServerConfig error message")];
        [self showRowError: errString
                      icon:self.iconRPCPath
                     label:self.labelRPCPath
               textControl:self.textRPCPath];
        success = NO;
    }
    else
    {
        [self showRowError:nil icon:self.iconRPCPath label:self.labelRPCPath textControl:nil];
        rpcPath = str;
    }
    
    if( !success )
    {
        self.errorMessage = errString;
        return success;
    }
    
    // when all values is ok, save config
    self.config.port = port;
    self.config.host = host;
    self.config.name = serverName;
    self.config.rpcPath = rpcPath;
    
    self.config.userName = [self trimString: self.textUserName.text];
    self.config.userPassword = [self trimString: self.textUserPassword.text];
    self.config.useSSL = self.switchUseSSL.on;
    
    self.config.refreshTimeout = (int)self.stepperRefreshTimeout.value;
    self.config.requestTimeout = (int)self.stepperRequestTimeout.value;
    
    self.config.showFreeSpace = self.switchShowFreeSpace.on;
    
    self.errorMessage = nil;
    
    return YES;
}

- (IBAction)requestTimeoutValueChagned:(UIStepper*)sender
{
    self.labelRequestTimeoutNumber.text = [NSString stringWithFormat:@"%02i", (int)sender.value];
}

- (IBAction)refreshTimoutValueChanged:(UIStepper*)sender
{
    if( sender.value == 0 )
        self.labelRefreshTimeoutNumber.text =  NSLocalizedString(@"OFF", @"RPCServerConfig timeouf message is OFF");
    else
        self.labelRefreshTimeoutNumber.text = [NSString stringWithFormat:@"%02i", (int)sender.value];
}
@end
