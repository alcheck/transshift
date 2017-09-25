//
//  WaitViewController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 21.04.16.
//  Copyright © 2016 Alexey Chechetkin. All rights reserved.
//

#import "WaitViewController.h"

@interface WaitViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIImageView *iconStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeout;

@end

@implementation WaitViewController

{
    NSTimeInterval _curTick;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    if( _statusText )
        _labelStatus.text = _statusText;
    
    // start timer if timeout is set
    if( _activityTimeout > 0 )
    {
        _curTick = _activityTimeout;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
}

- (void)timerTick:(NSTimer *)timer
{
    _labelTimeout.text = [NSString stringWithFormat:@"%02ld", (long)_curTick];
    
    _curTick--;
    
    if( _curTick < 0 )
    {
        [timer invalidate];
    }
}

- (void)stopActivity
{
    [_indicator stopAnimating];
    _labelTimeout.hidden = YES;
    _iconStatus.hidden = NO;
}

- (void)setStatusText:(NSString *)statusText
{
    _statusText = statusText;
    
    if( _labelStatus )
        _labelStatus.text = statusText;
}

@end
