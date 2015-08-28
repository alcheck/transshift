//
//  TorrentTitleSectionHeaderView.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 09.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentTitleSectionHeaderView.h"

@implementation TorrentTitleSectionHeaderView

+ (TorrentTitleSectionHeaderView *)titleSection
{
    TorrentTitleSectionHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"torrentTitleSectionHeader" owner:self options:nil] firstObject];
    //view.icon.image = [view.icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return view;
}

@end
