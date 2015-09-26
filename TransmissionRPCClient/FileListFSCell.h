//
//  FileListFSCell.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 03.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"
#import "IconFS.h"

#define CELL_ID_FILELISTFSCELL                      @"fileListFSCell"
#define FILELISTFSCELL_LEFTLABEL_WIDTH              28
#define FILELISTFSCELL_LEFTLABEL_LEVEL_INDENTATION  15

@class FileListTouchAreaView;

@interface FileListFSCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;
@property (weak, nonatomic) IBOutlet IconFS *icon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailToSegmentConstraint;

@property (weak, nonatomic) IBOutlet FileListTouchAreaView *touchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkBoxWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkBoxLeadConstraint;
@property (weak, nonatomic) IBOutlet CheckBox *checkBox;

// Touch recognizer
@property ( nonatomic ) UITapGestureRecognizer       *tapRecognizer;
@property ( nonatomic ) UILongPressGestureRecognizer *longTapRecognizer;

@end
