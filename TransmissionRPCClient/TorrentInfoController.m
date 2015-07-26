//
//  TorrentInfoController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentInfoController.h"

@interface TorrentInfoController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *torrentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *haveLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadedLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratioLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAddedLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCompletedLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLastActivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepperQueuePosition;
@property (weak, nonatomic) IBOutlet UILabel *queuePositionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentBandwidthPriority;
@property (weak, nonatomic) IBOutlet UISwitch *switchUploadLimit;
@property (weak, nonatomic) IBOutlet UITextField *textUploadLimit;
@property (weak, nonatomic) IBOutlet UISwitch *switchDownloadLimit;
@property (weak, nonatomic) IBOutlet UITextField *textDownloadLimit;
@property (weak, nonatomic) IBOutlet UISwitch *switchRatioLimit;
@property (weak, nonatomic) IBOutlet UITextField *textSeedRatioLimit;
@property (weak, nonatomic) IBOutlet UISwitch *switchSeedIdleLimit;
@property (weak, nonatomic) IBOutlet UITextField *textSeedIdleLimit;

@property(nonatomic) BOOL enableControls;


@end

@implementation TorrentInfoController

{
    UIBarButtonItem *_deleteButton;
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_pauseButton;
    UIBarButtonItem *_playButton;
    UIBarButtonItem *_spacerButton;
    UIBarButtonItem *_checkButton;
    UIBarButtonItem *_applyButton;
    
    NSURL   *_commentURL;
    
    TRInfo *_torrentInfo;
    
    BOOL _bFirstTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;

    _deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTorrent)];
    
    _refreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconReannounce20x20"]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(reannounceTorrent)];
    
    _pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopTorrent)];
    _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startTorrent)];
    _spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _checkButton = [[UIBarButtonItem alloc] initWithTitle:@"Verify" style:UIBarButtonItemStylePlain target:self action:@selector(verifyTorrent)];
    _applyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(applyIndividualTorrentSettings)];
    
    _applyButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = _applyButton;
    
    // configure pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(sendRequestForUpdateInfo) forControlEvents:UIControlEventValueChanged];
    
    self.enableControls = NO;
    
    _bFirstTime = YES;
}

- (void)applyIndividualTorrentSettings
{
    TRInfo *info = [[TRInfo alloc] init];
    
    info.bandwidthPriority = _segmentBandwidthPriority.selectedSegmentIndex - 1;
    info.queuePosition = (int)_stepperQueuePosition.value;
    
    info.uploadLimitEnabled = _switchUploadLimit.on;
    info.uploadLimit = [_textUploadLimit.text intValue];
    if( info.uploadLimitEnabled && info.uploadLimit <= 0 )
    {
        self.errorMessage = NSLocalizedString(@"Upload limit must be greater then zero", @"");
        return;
    }
    
    info.downloadLimitEnabled = _switchDownloadLimit.on;
    info.downloadLimit = [_textDownloadLimit.text intValue];
    if( info.downloadLimitEnabled && info.downloadLimit <= 0 )
    {
        self.errorMessage = NSLocalizedString(@"Download limit must be greater then zero", @"");
        return;
    }
    
    info.seedRatioMode = _switchRatioLimit.on ? 1 : 0;
    info.seedRatioLimit = [_textSeedRatioLimit.text intValue];
    if( info.seedRatioMode > 0 && info.seedRatioLimit <= 0 )
    {
        self.errorMessage = NSLocalizedString(@"Seed ratio limit must be greater then zero", @"");
        return;
    }
    
    info.seedIdleMode = _switchSeedIdleLimit.on ? 1 : 0;
    info.seedIdleLimit = [_textSeedIdleLimit.text intValue];
    if( info.seedIdleMode && info.seedIdleLimit <= 0 )
    {
        self.errorMessage = NSLocalizedString(@"Seed idle limit must be greater then zero", @"");
        return;
    }
    
    self.errorMessage = nil;
    if( _delegate && [_delegate respondsToSelector:@selector(applyTorrentSettings:forTorrentWithId:)])
    {
        [_delegate applyTorrentSettings:info forTorrentWithId:_torrentId];
    }
}

- (void)setEnableControls:(BOOL)enableControls
{
    _enableControls = enableControls;
    
    NSArray *controls = @[ _stepperQueuePosition,
                                  _segmentBandwidthPriority,
                                  _switchDownloadLimit,
                                  _switchRatioLimit,
                                  _switchSeedIdleLimit,
                                  _switchUploadLimit
                        ];
    
    for( UIControl *control in controls )
        control.enabled = enableControls;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)sendRequestForUpdateInfo
{
    if( _delegate && [_delegate respondsToSelector:@selector(updateTorrentInfoWithId:)])
        [_delegate updateTorrentInfoWithId:_torrentId];
}

- (void)showErrorMessage: (NSString *)msg
{
    [self.refreshControl endRefreshing];
    
    // tableview header
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectZero];
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

- (void)stopTorrent
{
    if( _delegate && [_delegate respondsToSelector:@selector(stopTorrentWithId:)])
    {
        _pauseButton.enabled = NO;
        [_delegate stopTorrentWithId:_torrentId];
    }
}

- (void)startTorrent
{
    if( _delegate && [_delegate respondsToSelector:@selector(resumeTorrentWithId:)] )
    {
        _playButton.enabled = NO;
        [_delegate resumeTorrentWithId:_torrentId];
    }
}

- (void)deleteTorrent
{
    // show action list
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:  NSLocalizedString(@"Remove torrent: %@?",@""), _torrentInfo.name]
                                                             delegate:self
                                                    cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle: NSLocalizedString(@"Remove", @"")
                                                    otherButtonTitles: NSLocalizedString(@"Remove with data", @""), nil];
    
    [actionSheet showFromBarButtonItem:_deleteButton animated:YES];
}

- (void)reannounceTorrent
{
    if( _delegate && [_delegate respondsToSelector:@selector(reannounceTorrentWithId:)] )
    {
        _refreshButton.enabled = NO;
        [_delegate reannounceTorrentWithId:_torrentId];
    }
}

- (void)verifyTorrent
{
    if( _delegate && [_delegate respondsToSelector:@selector(verifyTorrentWithId:)] )
    {
        //_playButton.enabled = NO;
        [_delegate verifyTorrentWithId:_torrentId];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

// open browser
- (void)commentLinkTapped
{
    [[UIApplication sharedApplication] openURL:_commentURL];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( !_delegate )
        return;
    
    // get the selected cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // track cell id - call appropriate method
    if ( [cell.reuseIdentifier isEqualToString:CELL_ID_SHOWPEERS] )
    {
        if ([_delegate respondsToSelector:@selector(showPeersForTorrentWithId:)])
            [_delegate showPeersForTorrentWithId:_torrentId];
    }
    else if( [cell.reuseIdentifier isEqualToString:CELL_ID_SHOWFILES] )
    {
        if( [_delegate respondsToSelector:@selector(showFilesForTorrentWithId:)])
            [_delegate showFilesForTorrentWithId:_torrentId];
    }
    else if( [cell.reuseIdentifier isEqualToString:CELL_ID_SHOWTRACKERS] )
    {
        if( [_delegate respondsToSelector:@selector((showTrackersForTorrentWithId:))] )
            [_delegate showTrackersForTorrentWithId:_torrentId];
    }
}

#pragma mark - Updating data methods

// update information
- (void)updateData:(TRInfo *)trInfo
{
    _torrentInfo = trInfo;
    
    [self.refreshControl endRefreshing];
    
    _playButton.enabled = YES;
    _pauseButton.enabled = YES;
    _refreshButton.enabled = YES;

    
    UIBarButtonItem *stopResumeButton = trInfo.isStopped ? _playButton : _pauseButton;
    
    stopResumeButton.enabled = !trInfo.isChecking;
    self.toolbarItems = @[stopResumeButton, _spacerButton, _refreshButton, _spacerButton, _deleteButton];
    
    //self.title = trInfo.name;
    self.title =  NSLocalizedString(@"Torrent details", @"TorrentInfoController title");
    
    self.torrentNameLabel.text = trInfo.name;
    self.stateLabel.text = trInfo.statusString;
    
    self.progressLabel.text =  trInfo.isChecking ? trInfo.recheckProgressString : trInfo.percentsDoneString;
    
    self.haveLabel.text = trInfo.haveValidString;
    self.downloadedLabel.text = trInfo.downloadedEverString;
    self.uploadedLabel.text = trInfo.uploadedEverString;
    self.ratioLabel.text = [NSString stringWithFormat:@"%02.2f",trInfo.uploadRatio];
    //self.commentLabel.text = trInfo.comment;
    self.dateAddedLabel.text = trInfo.dateAddedString;
    self.dateCompletedLabel.text = trInfo.dateDoneString;
    self.dateCreatedLabel.text = trInfo.dateCreatedString;
    self.dateLastActivityLabel.text = trInfo.dateLastActivityString;
    self.creatorLabel.text = trInfo.creator;
    self.downloadingTimeLabel.text = trInfo.downloadingTimeString;
    self.uploadingTimeLabel.text = trInfo.seedingTimeString;
    self.hashLabel.text = trInfo.hashString;
    
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSTextCheckingResult *match = [detector firstMatchInString:trInfo.comment options:0 range:NSMakeRange(0, trInfo.comment.length)];
    
    self.commentLabel.text = trInfo.comment;

    // detecting urls in comment line
    if( match.resultType == NSTextCheckingTypeLink )
    {
        _commentURL = match.URL;
        self.commentLabel.textColor = [UIColor blueColor];
        self.commentLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentLinkTapped)];
        [self.commentLabel addGestureRecognizer:tapRecognizer];
    }
    else
    {
        self.commentLabel.userInteractionEnabled = NO;
        self.commentLabel.text = trInfo.comment;
    }
    
    if( trInfo.errorString && trInfo.errorString.length > 0 )
    {
        NSString *errMessage = [NSString stringWithFormat:@"[%i] %@", trInfo.errorNumber, trInfo.errorString];
        [self showErrorMessage:errMessage];
    }
    
    if( _bFirstTime )
    {
        // set changable values
        _stepperQueuePosition.value = trInfo.queuePosition;
        _queuePositionLabel.text = [NSString stringWithFormat:@"%i", trInfo.queuePosition];
        
        _segmentBandwidthPriority.selectedSegmentIndex = trInfo.bandwidthPriority + 1;
        
        _switchUploadLimit.on = trInfo.uploadLimitEnabled;
        _switchDownloadLimit.on = trInfo.downloadLimitEnabled;
        _switchRatioLimit.on = trInfo.seedRatioMode > 0;
        _switchSeedIdleLimit.on = trInfo.seedIdleMode > 0;
        
        _textUploadLimit.text = [NSString stringWithFormat:@"%i", trInfo.uploadLimit];
        _textDownloadLimit.text = [NSString stringWithFormat:@"%i", trInfo.downloadLimit];
        _textSeedIdleLimit.text = [NSString stringWithFormat:@"%i", trInfo.seedIdleLimit];
        _textSeedRatioLimit.text = [NSString stringWithFormat:@"%i", trInfo.seedRatioLimit];
        
        //_applyButton.enabled = YES;
        self.enableControls = YES;
        _bFirstTime = NO;
    }
}

#pragma mark - ActionSheeDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( !_delegate || ![_delegate respondsToSelector:@selector(deleteTorrentWithId:deleteWithData:)])
        return;
    
    if( actionSheet.destructiveButtonIndex == buttonIndex )
    {
        // delete;
        //NSLog(@"TorrentInfoController: deleting torrent");
        [_delegate deleteTorrentWithId:_torrentId deleteWithData:NO];
    }
    else if( buttonIndex == 1 )
    {
        // delete with data
        //NSLog(@"TorrentInfoController: deleting torrent with data");
        [_delegate deleteTorrentWithId:_torrentId deleteWithData:YES];
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    _deleteButton.enabled = NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _deleteButton.enabled = YES;
}

- (IBAction)queuePositionChanged:(UIStepper *)sender
{
    _queuePositionLabel.text = [NSString stringWithFormat:@"%i", (int)sender.value];
    _applyButton.enabled = YES;
}

- (IBAction)uploadLimitChanged:(UISwitch *)sender
{
    _textUploadLimit.enabled = sender.on;
    _applyButton.enabled = YES;
}

- (IBAction)downloadLimitChanged:(UISwitch *)sender
{
    _textDownloadLimit.enabled = sender.on;
    _applyButton.enabled = YES;
}

- (IBAction)seedRatioLimitChanged:(UISwitch *)sender
{
    _textSeedRatioLimit.enabled = sender.on;
    _applyButton.enabled = YES;
}

- (IBAction)seedIdleLimitChanged:(UISwitch *)sender
{
    _textSeedIdleLimit.enabled = sender.on;
    _applyButton.enabled = YES;
}

@end
