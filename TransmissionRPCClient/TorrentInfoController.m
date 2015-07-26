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

@end

@implementation TorrentInfoController

{
    UIBarButtonItem *_deleteButton;
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_pauseButton;
    UIBarButtonItem *_playButton;
    UIBarButtonItem *_spacerButton;
    UIBarButtonItem *_checkButton;
    
    NSURL   *_commentURL;
    
    TRInfo *_torrentInfo;
}

- (void)viewDidLoad {
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
    
    // configure pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(sendRequestForUpdateInfo) forControlEvents:UIControlEventValueChanged];
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

@end
