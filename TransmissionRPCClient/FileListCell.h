//
//  FileListCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 30.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_ID_FILELIST    @"fileListCell"

@interface FileListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *indendLabel;
@property (weak, nonatomic) IBOutlet UISwitch *wantedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;

@end
