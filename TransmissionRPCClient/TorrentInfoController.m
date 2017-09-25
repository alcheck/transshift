//
//  TorrentInfoController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentInfoController.h"
#import "MagnetURLViewController.h"
#import "WaitViewController.h"
#import "IpAnonimizer.h"
#import "GlobalConsts.h"
#import "InfoMenuLabel.h"

#define CELL_ID_SHOWPEERS           @"showPeersId"
#define CELL_ID_SHOWFILES           @"showFilesId"
#define CELL_ID_SHOWTRACKERS        @"showTrackersId"
#define CELL_ID_SHOWMAGNETURL       @"showMagnetUrlId"


@interface TorrentInfoController () <UIActionSheetDelegate, InfoMenuLabelDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoading;
@property (weak, nonatomic) IBOutlet InfoMenuLabel *torrentNameLabel;
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
@property (weak, nonatomic) IBOutlet UITextView *hashTextView;
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
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *upDownSpeedLabel;

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
    
    BOOL _bWaitingStatusChange;
    int  _oldStatus;
    
    UIPopoverController *_popOver;
    MagnetURLViewController *_magnetUrlController;
    
    UITapGestureRecognizer *_torrentNameLabelGesture;
    UITapGestureRecognizer *_torrentPiecesLabelGesture;
    UITapGestureRecognizer *_torrentCommentLabelGesture;
    
    /// holds UIActionSheet for open link actions
    UIActionSheet *_openLinkActions;
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
    _applyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply", @"") style:UIBarButtonItemStylePlain target:self action:@selector(applyIndividualTorrentSettings)];
    
    _applyButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = _applyButton;
    
    // configure pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(sendRequestForUpdateInfo) forControlEvents:UIControlEventValueChanged];
    
    self.enableControls = NO;
    
    _bFirstTime = YES;
    _bWaitingStatusChange = NO;
}

- (void)applyIndividualTorrentSettings
{
    TRInfo *info = [[TRInfo alloc] init];
    
    info.bandwidthPriority = (int)_segmentBandwidthPriority.selectedSegmentIndex - 1;
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
    info.seedRatioLimit = [_textSeedRatioLimit.text floatValue];
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
    
    NSArray *controls = @[        _stepperQueuePosition,
                                  _segmentBandwidthPriority,
                                  _switchDownloadLimit,
                                  _switchRatioLimit,
                                  _switchSeedIdleLimit,
                                  _switchUploadLimit,
                                  _textDownloadLimit,
                                  _textSeedIdleLimit,
                                  _textSeedRatioLimit,
                                  _textUploadLimit
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

- (void)stopTorrent
{
    if( _delegate && [_delegate respondsToSelector:@selector(stopTorrentWithId:)])
    {
        _pauseButton.enabled = NO;
        
        _bWaitingStatusChange = YES;
        _oldStatus = _torrentInfo.status;
        _stateLabel.text = NSLocalizedString(@"Updating ...", @"");
        
        [_delegate stopTorrentWithId:_torrentId];
    }
}

- (void)startTorrent
{
    if( _delegate && [_delegate respondsToSelector:@selector(resumeTorrentWithId:)] )
    {
        _playButton.enabled = NO;
        
        _bWaitingStatusChange = YES;
        _oldStatus = _torrentInfo.status;
        _stateLabel.text = NSLocalizedString(@"Updating ...", @"");
        
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
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

// open browser
- (void)commentLinkTapped
{
    // show action list to allow user
    // open link in browser,
    // copy this link to buffer
    // or open this link via anonimizer service
    
    _openLinkActions = [[UIActionSheet alloc] initWithTitle: _commentURL.absoluteString // NSLocalizedString(@"Open link menu", nil)
                                                   delegate:self
                                          cancelButtonTitle:self.splitViewController ?  nil : NSLocalizedString(@"Cancel", nil)
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Open in Safari", nil),
                                                            NSLocalizedString(@"Open via Anonimizer", nil),
                                                            NSLocalizedString(@"Copy", nil),
                                                            nil];
    
    CGRect r = _commentLabel.bounds;
    r.origin.x += r.size.width / 2.0f - 20.0f;
    r.origin.y += r.size.height / 2.0f;
    r.size.width = 40.0f;
    r.size.height /= 2.0f;
    
    [_openLinkActions showFromRect:r inView:_commentLabel animated:YES];
}

/// Handle file/trackers/peers rows touch
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( !_delegate || _torrentInfo == nil )
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
    else if( [cell.reuseIdentifier isEqualToString:CELL_ID_SHOWMAGNETURL] )
    {
        // show controller with magnet url
        if( _delegate && [_delegate respondsToSelector:@selector(getMagnetURLforTorrentWithId:)] )
        {
            _magnetUrlController = instantiateController( CONTROLLER_ID_MAGNETURL );
            
            if( self.splitViewController )
            {
                if( _popOver )
                    [_popOver dismissPopoverAnimated:NO];
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_magnetUrlController];
                _popOver = [[UIPopoverController alloc] initWithContentViewController:nav];
                CGRect r = cell.bounds;
                r.origin.y += r.size.height / 2;
                r.size.height = r.size.height / 2;
                [_popOver presentPopoverFromRect:r inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            else
            {
                [self.navigationController pushViewController:_magnetUrlController animated:YES];
            }
            
            [_delegate getMagnetURLforTorrentWithId:_torrentId];
        }
    }
}

- (void)setMagnetURL:(NSString *)magnetURL
{
    _magnetUrlController.urlString = magnetURL;
}

- (void)showMenuForTorrentName
{
    [self.torrentNameLabel becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    UIMenuItem *itemRenameTorrent = [[UIMenuItem alloc] initWithTitle: NSLocalizedString( @"Rename torrent", nil) action:@selector(customMenuAction:)];
    
    menu.menuItems = @[itemRenameTorrent];
    
    [menu setTargetRect:self.torrentNameLabel.frame inView:self.torrentNameLabel.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (void)InfoMenuLabelSetNewName:(NSString *)newName
{
    // renaming torrent
    if( _delegate && [_delegate respondsToSelector:@selector(renameTorrentWithId:withNewName:andPath:)] )
    {
        // NSString *path = [NSString stringWithFormat:@"%@/%@", _torrentInfo.downloadDir, _torrentInfo.name];
       [_delegate renameTorrentWithId:_torrentId withNewName:newName andPath:_torrentInfo.name];
    }
}

- (void)showPiecesLegend
{
    if( _delegate && [_delegate respondsToSelector:@selector(showPiecesLegendForTorrentWithId:piecesCount:pieceSize:)])
    {
        [_delegate showPiecesLegendForTorrentWithId:_torrentId piecesCount:_torrentInfo.piecesCount pieceSize:_torrentInfo.pieceSize];
    }
}


#pragma mark - Updating data methods

// update information
- (void)updateData:(TRInfo *)trInfo
{
    [self.refreshControl endRefreshing];
    
    // FIX: no need to continue if there is no data model
    if( trInfo == nil )
        return;

    [_indicatorLoading stopAnimating];
    
    _torrentInfo = trInfo;
    
    _playButton.enabled = YES;
    _pauseButton.enabled = YES;
    _refreshButton.enabled = YES;
    
    UIBarButtonItem *stopResumeButton = trInfo.isStopped ? _playButton : _pauseButton;
    
    stopResumeButton.enabled = !trInfo.isChecking;
    self.toolbarItems = @[stopResumeButton, _spacerButton, _refreshButton, _spacerButton, _deleteButton];
    
    self.title =  NSLocalizedString(@"Torrent details", nil);
    
    self.torrentNameLabel.text = trInfo.name;
    
    if( !_torrentNameLabelGesture )
    {
        self.torrentNameLabel.userInteractionEnabled = YES;
        self.torrentNameLabel.textColor = self.view.tintColor;
        self.torrentNameLabel.delegate = self;
        _torrentNameLabelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuForTorrentName)];
        [self.torrentNameLabel addGestureRecognizer:_torrentNameLabelGesture];
    }
    
    
    if( !_bWaitingStatusChange )
    {
        self.stateLabel.text = trInfo.statusString;
    }
    else if( _oldStatus != trInfo.status )
    {
        stopResumeButton.enabled = YES;
        self.stateLabel.text = trInfo.statusString;
        _bWaitingStatusChange = NO;
    }
    else
    {
        stopResumeButton.enabled = NO;
        self.stateLabel.text = NSLocalizedString( @"Updating ...", nil );
    }
    
    self.progressLabel.text =  trInfo.isChecking ? trInfo.recheckProgressString : trInfo.percentsDoneString;
    
    self.haveLabel.text = trInfo.haveValidString;
    
    self.sizeLabel.text = [NSString stringWithFormat: NSLocalizedString(@"TorrentInfoSizeFormat", nil),
                           trInfo.totalSizeString, trInfo.piecesCount, trInfo.pieceSizeString];
    
    if( !_torrentPiecesLabelGesture )
    {
        self.sizeLabel.userInteractionEnabled = YES;
        self.sizeLabel.textColor = self.view.tintColor;
        _torrentPiecesLabelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPiecesLegend)];
        [self.sizeLabel addGestureRecognizer:_torrentPiecesLabelGesture];
    }
    
    
    self.downloadedLabel.text = trInfo.downloadedEverString;
    self.uploadedLabel.text = trInfo.uploadedEverString;
    
    self.upDownSpeedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TorrentUpDownSpeedFormat", nil),
                                  trInfo.uploadRateString, trInfo.downloadRateString ];
    
    self.ratioLabel.text = [NSString stringWithFormat:@"%02.2f",trInfo.uploadRatio];
    
    self.dateAddedLabel.text = trInfo.dateAddedString;
    self.dateCompletedLabel.text = trInfo.dateDoneString;
    self.dateCreatedLabel.text = trInfo.dateCreatedString;
    self.dateLastActivityLabel.text = trInfo.dateLastActivityString;
    self.creatorLabel.text = trInfo.creator;
    self.downloadingTimeLabel.text = trInfo.downloadingTimeString;
    self.uploadingTimeLabel.text = trInfo.seedingTimeString;
    self.hashTextView.text = trInfo.hashString;
    
    // handle torrent info where info is link to torrent
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSTextCheckingResult *match = [detector firstMatchInString:trInfo.comment options:0 range:NSMakeRange(0, trInfo.comment.length)];
    
    self.commentLabel.text = trInfo.comment;

    // detecting urls in comment line
    if( match.resultType == NSTextCheckingTypeLink && !_torrentCommentLabelGesture )
    {
        _commentURL = match.URL;
        self.commentLabel.textColor = self.view.tintColor;
        self.commentLabel.userInteractionEnabled = YES;
        _torrentCommentLabelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentLinkTapped)];
        [self.commentLabel addGestureRecognizer:_torrentCommentLabelGesture];
    }
    
    // if this torrent has some error, show this error in header
    if( trInfo.errorString && trInfo.errorString.length > 0 )
    {
        NSString *errMessage = [NSString stringWithFormat:@"[%i] %@", trInfo.errorNumber, trInfo.errorString];
        self.errorMessage = errMessage;
    }
    
    // init some ui only once
    if( _bFirstTime )
    {
        self.enableControls = YES;

        // set changable values
        _stepperQueuePosition.value = trInfo.queuePosition;
        _queuePositionLabel.text = [NSString stringWithFormat:@"%i", trInfo.queuePosition];
        
        _segmentBandwidthPriority.selectedSegmentIndex = trInfo.bandwidthPriority + 1;
        
        _switchUploadLimit.on = trInfo.uploadLimitEnabled;
        _switchDownloadLimit.on = trInfo.downloadLimitEnabled;
        _switchRatioLimit.on = trInfo.seedRatioMode > 0;
        _switchSeedIdleLimit.on = trInfo.seedIdleMode > 0;
        
        [_switchUploadLimit     sendActionsForControlEvents:UIControlEventValueChanged];
        [_switchDownloadLimit   sendActionsForControlEvents:UIControlEventValueChanged];
        [_switchRatioLimit      sendActionsForControlEvents:UIControlEventValueChanged];
        [_switchSeedIdleLimit   sendActionsForControlEvents:UIControlEventValueChanged];
        
        _textUploadLimit.text = [NSString stringWithFormat:@"%i", trInfo.uploadLimit];
        _textDownloadLimit.text = [NSString stringWithFormat:@"%i", trInfo.downloadLimit];
        _textSeedIdleLimit.text = [NSString stringWithFormat:@"%i", trInfo.seedIdleLimit];
        _textSeedRatioLimit.text = [NSString stringWithFormat:@"%.2f", trInfo.seedRatioLimit];
        
        _applyButton.enabled = NO;
        _bFirstTime = NO;
    }
}

#pragma mark - ActionSheeDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( !_delegate || ![_delegate respondsToSelector:@selector(deleteTorrentWithId:deleteWithData:)])
        return;
    
    // handle all actions for OpenLink actions
    if( actionSheet == _openLinkActions )
    {
        // the first button - open in safari
        if( actionSheet.firstOtherButtonIndex == buttonIndex )
        {
            [[UIApplication sharedApplication] openURL:_commentURL];
        }
        // open in anonimizer
        else if( (actionSheet.firstOtherButtonIndex + 1) == buttonIndex )
        {
            WaitViewController *vc = instantiateController( CONTROLLER_ID_WAIT );
            vc.statusText = NSLocalizedString( @"Getting url", nil );
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            vc.activityTimeout  = IpAnonimizer.requestTimeout;
            
            // FIX: present view controller after some time
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self presentViewController:vc animated:YES completion:nil];
                
                // make request and dismiss view controller after time
                [IpAnonimizer requestAnonimUrlForUrl:_commentURL usingComplitionHandler:^(NSError *err, NSURL *url) {
                    // if there is some error - show this error and dismiss
                    // view controller after several seconds
                    if( err )
                    {
                        vc.statusText = err.localizedDescription;
                        [vc stopActivity];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [vc dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                    else
                    {
                        // open this link if safari and dismiss viewcontroller
                        [vc dismissViewControllerAnimated:NO completion:nil];
                        
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }];
            });
        }
        // copy link to buffer
        else
        {
            [[UIPasteboard generalPasteboard] setURL:_commentURL];
        }
        
        return;
    }
    
    // handle all actions for Deleteing torrent
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
- (IBAction)bandwidthPriorityChanged:(UISegmentedControl *)sender
{
    _applyButton.enabled = YES;
}

- (IBAction)textFieldChanged:(id)sender
{
    _applyButton.enabled = YES;
}
@end
