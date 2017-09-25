//
//  ServerListFooterView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ServerListFooterView.h"

static NSString *const kViewName = @"ServerListFooterView";
static NSString *const kAppURL = @"http://transshift.16mb.com";

@implementation ServerListFooterView

{
    CGFloat _originalHeight;
}

+ (instancetype)view
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:kViewName owner:self options:nil];
    ServerListFooterView *view = [views firstObject];
    
    return view;
}

- (void)setBoundsFromTableView:(UITableView *)tableView
{
    CGRect r = self.bounds;
    r.size.width = tableView.bounds.size.width;
    r.size.height = _originalHeight;
    self.bounds = r;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _originalHeight = self.bounds.size.height;
}

- (IBAction)openAppWebSite:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppURL]];
}

@end
