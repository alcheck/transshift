//
//  ServerListFooterView.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerListFooterView : UIView

+ (instancetype)view;
- (void)setBoundsFromTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelCopyright;

@end
