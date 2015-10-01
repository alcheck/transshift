//
//  SessionConfigController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "SessionConfigController.h"
#import "ScheduleAltLimitsController.h"

@interface SessionConfigController () <UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *switchDownloadRateEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textDownloadRateNumber;

@property (weak, nonatomic) IBOutlet UISwitch *switchUploadRateEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textUploadRateNumber;

@property (weak, nonatomic) IBOutlet UISwitch *switchAltDownloadRateEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textAltDownloadRateNumber;
@property (weak, nonatomic) IBOutlet UISwitch *switchAltUploadRateEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textAltUploadRateNumber;

@property (weak, nonatomic) IBOutlet UISwitch *switchAddPartToUnfinishedFiles;
@property (weak, nonatomic) IBOutlet UISwitch *switchStartDownloadImmidiately;

@property (weak, nonatomic) IBOutlet UISwitch *switchSeedRatioLimitEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textSeedRatioLimitNumber;

@property (weak, nonatomic) IBOutlet UISwitch *switchIdleSeedEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textIdleSeedNumber;

@property (weak, nonatomic) IBOutlet UITextField *textTotalPeersCountNumber;
@property (weak, nonatomic) IBOutlet UITextField *textPeersPerTorrentNumber;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentEncryption;

@property (weak, nonatomic) IBOutlet UISwitch *switchDHTEnabled;
@property (weak, nonatomic) IBOutlet UISwitch *switchPEXEnabled;
@property (weak, nonatomic) IBOutlet UISwitch *switchLPDEnabled;
@property (weak, nonatomic) IBOutlet UISwitch *switchUTPEnabled;

@property (weak, nonatomic) IBOutlet UISwitch *switchRandomPortEnabled;
@property (weak, nonatomic) IBOutlet UISwitch *switchPortForwardingEnabled;
@property (weak, nonatomic) IBOutlet UITextField *textPortNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelPort;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorPortCheck;

@property(nonatomic) BOOL enableControls;
@property (weak, nonatomic) IBOutlet UITextField *textDownloadDir;
@property (weak, nonatomic) IBOutlet UISwitch *switchScheduleAltLimits;

//@property (weak, nonatomic) IBOutlet UIButton *buttonShowScheduler;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentShowScheduler;

@end

@implementation SessionConfigController

{
    NSArray *_controls;
    UIPopoverController *_popOver;
    ScheduleAltLimitsController *_scheduleController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.enableControls = NO;
    
    self.title =  NSLocalizedString(@"Settings", @"SessionConfigController title");
    
    [_segmentShowScheduler removeSegmentAtIndex:1 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self saveAltLimitsSchedulerSettings];
}

- (void)saveAltLimitsSchedulerSettings
{
    _segmentShowScheduler.selectedSegmentIndex = -1;
    
    if( _scheduleController )
    {
        _sessionInfo.altLimitDay = _scheduleController.daysMask;
        _sessionInfo.altLimitTimeBegin = _scheduleController.timeBegin;
        _sessionInfo.altLimitTimeEnd = _scheduleController.timeEnd;
    }
}

- (void)setSessionInfo:(TRSessionInfo *)sessionInfo
{
    _sessionInfo = sessionInfo;
    [self loadConfig];
}

// returns YES if config values is ok
- (BOOL)saveConfig
{
    _sessionInfo.downLimitEnabled = _switchDownloadRateEnabled.on;
    _sessionInfo.upLimitEnabled = _switchUploadRateEnabled.on;

    NSString *downloadDir = [_textDownloadDir.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if( downloadDir.length < 1 )
    {
        self.errorMessage = NSLocalizedString(@"You shoud set download directory", @"");
        return NO;
    }
    
    _sessionInfo.downloadDir = downloadDir;
    
    if( _sessionInfo.downLimitEnabled )
    {
        _sessionInfo.downLimitRate = [_textDownloadRateNumber.text intValue];
        if( _sessionInfo.downLimitRate <= 0 || _sessionInfo.downLimitRate >= 1000000 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong download rate limit", @"");
            return NO;
        }
    }
    
    if( _sessionInfo.upLimitEnabled )
    {
        _sessionInfo.upLimitRate = [_textUploadRateNumber.text intValue];
        if (_sessionInfo.upLimitRate <= 0 || _sessionInfo.upLimitRate >= 1000000 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong upload rate limit", @"");
            return NO;
        }
    }
    
    _sessionInfo.altLimitEnabled = _switchAltDownloadRateEnabled.on || _switchAltUploadRateEnabled.on;
    if( _sessionInfo.altLimitEnabled )
    {
        _sessionInfo.altDownloadRateLimit = [_textAltDownloadRateNumber.text intValue];
        if( _sessionInfo.altDownloadRateLimit <=0 || _sessionInfo.altDownloadRateLimit >= 1000000 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong alternative download rate limit", @"");
            return NO;
        }
        
        _sessionInfo.altUploadRateLimit = [_textAltUploadRateNumber.text intValue];
        if( _sessionInfo.altUploadRateLimit <=0 || _sessionInfo.altUploadRateLimit >= 1000000 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong alternative upload rate limit", @"");
            return NO;
        }
    }
    
    _sessionInfo.addPartToUnfinishedFilesEnabled = _switchAddPartToUnfinishedFiles.on;
    _sessionInfo.startDownloadingOnAdd = _switchStartDownloadImmidiately.on;
    
    _sessionInfo.seedRatioLimitEnabled = _switchSeedRatioLimitEnabled.on;
    if( _sessionInfo.seedRatioLimitEnabled )
    {
        _sessionInfo.seedRatioLimit = [_textSeedRatioLimitNumber.text floatValue];
        if( _sessionInfo.seedRatioLimit <=0 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong seed ratio limit factor", @"");
            return NO;
        }
    }
    
    _sessionInfo.seedIdleLimitEnabled = _switchIdleSeedEnabled.on;
    if( _sessionInfo.seedIdleLimitEnabled )
    {
        _sessionInfo.seedIdleLimit = [_textIdleSeedNumber.text intValue];
        if( _sessionInfo.seedIdleLimit <= 0 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong seed idle timeout number", @"");
            return NO;
        }
    }
    
    _sessionInfo.globalPeerLimit = [_textTotalPeersCountNumber.text intValue];
    
    if( _sessionInfo.globalPeerLimit <=0 )
    {
        self.errorMessage = NSLocalizedString(@"Wrong total peers count", @"");
        return NO;
    }
    
    _sessionInfo.torrentPeerLimit = [_textPeersPerTorrentNumber.text intValue];
    if( _sessionInfo.torrentPeerLimit <= 0 || _sessionInfo.torrentPeerLimit > _sessionInfo.globalPeerLimit )
    {
        self.errorMessage = NSLocalizedString(@"Wrong peers per torrent count", @"");
        return NO;
    }
    
    _sessionInfo.encryptionId = (int)_segmentEncryption.selectedSegmentIndex;
    
    _sessionInfo.DHTEnabled = _switchDHTEnabled.on;
    _sessionInfo.PEXEnabled = _switchPEXEnabled.on;
    _sessionInfo.LPDEnabled = _switchLPDEnabled.on;
    _sessionInfo.UTPEnabled = _switchUTPEnabled.on;
    
    _sessionInfo.portForfardingEnabled = _switchPortForwardingEnabled.on;
    _sessionInfo.portRandomAtStartEnabled = _switchRandomPortEnabled.on;
    
    if (!_sessionInfo.portRandomAtStartEnabled)
    {
        _sessionInfo.port = [_textPortNumber.text intValue];
        if( _sessionInfo.port <= 0 || _sessionInfo.port > 65535 )
        {
            self.errorMessage = NSLocalizedString(@"Wrong port number", @"");
            return  NO;
        }
    }
    
    _sessionInfo.altLimitTimeEnabled = _switchScheduleAltLimits.on;

    if( _switchScheduleAltLimits.on )
        [self saveAltLimitsSchedulerSettings];
    
    self.errorMessage = nil;
    return YES;
}

- (void)loadConfig
{
    if( _sessionInfo )
    {
        self.enableControls = YES;
        // load config values
        _switchDownloadRateEnabled.on = _sessionInfo.downLimitEnabled;
        _textDownloadRateNumber.enabled = _sessionInfo.downLimitEnabled;
        _textDownloadRateNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.downLimitRate];
        
        _switchUploadRateEnabled.on = _sessionInfo.upLimitEnabled;
        _textUploadRateNumber.enabled = _sessionInfo.upLimitEnabled;
        _textUploadRateNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.upLimitRate];
        
        _switchAltDownloadRateEnabled.on = _sessionInfo.altLimitEnabled;
        _switchAltUploadRateEnabled.on = _sessionInfo.altLimitEnabled;
        
        _textAltDownloadRateNumber.enabled = _sessionInfo.altLimitEnabled;
        _textAltUploadRateNumber.enabled = _sessionInfo.altLimitEnabled;
        _textAltDownloadRateNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.altDownloadRateLimit];
        _textAltUploadRateNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.altUploadRateLimit];
        
        _switchAddPartToUnfinishedFiles.on = _sessionInfo.addPartToUnfinishedFilesEnabled;
        _switchStartDownloadImmidiately.on = _sessionInfo.startDownloadingOnAdd;
        
        _switchSeedRatioLimitEnabled.on = _sessionInfo.seedRatioLimitEnabled;
        _textSeedRatioLimitNumber.enabled = _sessionInfo.seedRatioLimitEnabled;
        _textSeedRatioLimitNumber.text = [NSString stringWithFormat:@"%0.1f", _sessionInfo.seedRatioLimit];
        
        _switchIdleSeedEnabled.on = _sessionInfo.seedIdleLimitEnabled;
        _textIdleSeedNumber.enabled = _sessionInfo.seedIdleLimitEnabled;
        _textIdleSeedNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.seedIdleLimit];
        
        _textTotalPeersCountNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.globalPeerLimit];
        _textPeersPerTorrentNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.torrentPeerLimit];
        
        _segmentEncryption.selectedSegmentIndex = _sessionInfo.encryptionId;
        _switchDHTEnabled.on = _sessionInfo.DHTEnabled;
        _switchPEXEnabled.on = _sessionInfo.PEXEnabled;
        _switchLPDEnabled.on = _sessionInfo.LPDEnabled;
        _switchUTPEnabled.on = _sessionInfo.UTPEnabled;
        
        _switchRandomPortEnabled.on = _sessionInfo.portRandomAtStartEnabled;
        _textPortNumber.enabled = !_sessionInfo.portRandomAtStartEnabled;
        _textPortNumber.text = [NSString stringWithFormat:@"%i", _sessionInfo.port];
        _switchPortForwardingEnabled.on = _sessionInfo.portForfardingEnabled;
        
        _labelPort.text = NSLocalizedString(@"testing ...", @"");
        _indicatorPortCheck.hidden = NO;
        [_indicatorPortCheck startAnimating];
        
        _textDownloadDir.enabled = YES;
        _textDownloadDir.text = _sessionInfo.downloadDir;
        
        _switchScheduleAltLimits.enabled = YES;
        _switchScheduleAltLimits.on = _sessionInfo.altLimitTimeEnabled;
        //_buttonShowScheduler.enabled = _switchScheduleAltLimits.on;
        _segmentShowScheduler.enabled = _switchScheduleAltLimits.on;
        _segmentShowScheduler.selectedSegmentIndex = -1;
        
        self.headerInfoMessage = [NSString stringWithFormat:@"Transmission %@", _sessionInfo.transmissionVersion];
        self.footerInfoMessage = [NSString stringWithFormat:NSLocalizedString(@"RPC Version: %@", @""), _sessionInfo.rpcVersion ];
    }
}

- (void)setPortIsOpen:(BOOL)portIsOpen
{
    [_indicatorPortCheck stopAnimating];
    _labelPort.textColor = portIsOpen ? [UIColor greenColor] : [UIColor redColor];
    _labelPort.text = portIsOpen ? NSLocalizedString(@"OPEN", @"Portinfo") : NSLocalizedString(@"CLOSED", @"Portinfo");
}

- (void)setEnableControls:(BOOL)enableControls
{
    _enableControls = enableControls;
    
    if( !_controls )
    {
            _controls = @[ _switchAddPartToUnfinishedFiles, _switchAltDownloadRateEnabled, _switchAltUploadRateEnabled,
                           _switchDHTEnabled, _switchDownloadRateEnabled, _switchIdleSeedEnabled, _switchLPDEnabled,
                           _switchPEXEnabled, _switchPortForwardingEnabled, _switchRandomPortEnabled, _switchSeedRatioLimitEnabled,
                           _switchStartDownloadImmidiately, _switchUploadRateEnabled, _switchUTPEnabled, _textAltDownloadRateNumber,
                           _textAltUploadRateNumber, _textDownloadRateNumber, _textIdleSeedNumber, _textPeersPerTorrentNumber, _textPortNumber,
                           _textSeedRatioLimitNumber, _textSeedRatioLimitNumber, _textTotalPeersCountNumber, _textUploadRateNumber, _segmentEncryption,
                           _textDownloadDir, _segmentShowScheduler
                          ];
    }
    
    for (UIControl *c in _controls)
        c.enabled = enableControls;
}

- (IBAction)toggleUploadRate:(UISwitch *)sender
{
    _textUploadRateNumber.enabled = sender.on;
}

- (IBAction)toggleDownloadRate:(UISwitch *)sender
{
    _textDownloadRateNumber.enabled = sender.on;
}

- (IBAction)toggleAltRate:(UISwitch *)sender
{
    BOOL on = sender.on;
    _textAltDownloadRateNumber.enabled = on;
    _textAltUploadRateNumber.enabled = on;
    _switchAltDownloadRateEnabled.on = on;
    _switchAltUploadRateEnabled.on = on;
}

- (IBAction)toggleSeedRatioLimit:(UISwitch*)sender
{
    _textSeedRatioLimitNumber.enabled = sender.on;
}

- (IBAction)toggleIdleSeedLimit:(UISwitch*)sender
{
    _textIdleSeedNumber.enabled = sender.on;
}

- (IBAction)toggleRandomPort:(UISwitch*)sender
{
    _textPortNumber.enabled = !sender.on;
}

- (IBAction)btnShowScheduler:(UISegmentedControl *)sender
{
    if( _switchScheduleAltLimits.on )
    {
        _scheduleController = instantiateController( CONTROLLER_ID_SCHEDULETIMEDATE );
        _scheduleController.title = NSLocalizedString(@"Schedule time", @"");
        
        //NSLog(@"Setting values ...");
        _scheduleController.daysMask = _sessionInfo.altLimitDay;
        _scheduleController.timeBegin = _sessionInfo.altLimitTimeBegin;
        _scheduleController.timeEnd = _sessionInfo.altLimitTimeEnd;
        
        if( self.splitViewController )
        {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_scheduleController];
            
            _popOver = [[UIPopoverController alloc] initWithContentViewController:nav];
            _popOver.delegate = self;
            
            [_popOver presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:_scheduleController animated:YES];
        }
    }
}

- (IBAction)scheduleOnOff:(UISwitch *)sender
{
    _segmentShowScheduler.enabled = sender.on;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self saveAltLimitsSchedulerSettings];
}

@end
