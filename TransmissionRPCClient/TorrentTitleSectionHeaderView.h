//
//  TorrentTitleSectionHeaderView.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 09.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TorrentTitleSectionHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *icon;


+ (TorrentTitleSectionHeaderView *)titleSection;

@end
