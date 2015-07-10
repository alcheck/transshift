//
//  HeaderViewDURates.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 07.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "HeaderViewDURates.h"

@interface HeaderViewDURates()

@property (weak, nonatomic) IBOutlet UIImageView *iconDL;
@property (weak, nonatomic) IBOutlet UILabel *labelDL;
@property (weak, nonatomic) IBOutlet UIImageView *iconUL;
@property (weak, nonatomic) IBOutlet UILabel *labelUL;
@property (weak, nonatomic) IBOutlet UIImageView *iconTurtle;

@property(nonatomic) UIImage *iconUp;
@property(nonatomic) UIImage *iconDown;
@property(nonatomic) UIImage *iconUpDown;

@end

@implementation HeaderViewDURates

{
    CGFloat _originalHeight;
}

+ (HeaderViewDURates*)view
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"HeaderViewDURates" owner:self options:nil];
    HeaderViewDURates *view = [views firstObject];
    
    view.iconDL.image = [view.iconDL.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    view.iconUL.image = [view.iconUL.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //view.iconTurtle.image = [view.iconTurtle.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    view.iconUp = [[UIImage imageNamed:@"iconTurtleUpload20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    view.iconDown = [[UIImage imageNamed:@"iconTurtleDownload20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    view.iconUpDown = [[UIImage imageNamed:@"iconTurtleUpDown20x20"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    view.iconDL.tintColor = view.labelDL.textColor;
    view.iconUL.tintColor = view.labelUL.textColor;
    view.iconTurtle.tintColor = view.tintColor;
    
    view.iconTurtle.hidden = YES;
    view.downLimitIsOn = NO;
    view.upLimitIsOn = NO;
    
    return view;
}

- (void)setUpLimitIsOn:(BOOL)upLimitIsOn
{
    _upLimitIsOn = upLimitIsOn;
    [self setLimitIcon];
}

- (void)setDownLimitIsOn:(BOOL)downLimitIsOn
{
    _downLimitIsOn = downLimitIsOn;
   [self setLimitIcon];
}


- (void)setLimitIcon
{
    self.iconTurtle.hidden = !(_upLimitIsOn || _downLimitIsOn);
    
    if( _downLimitIsOn && _upLimitIsOn )
        self.iconTurtle.image = self.iconUpDown;
    else if( _downLimitIsOn )
        self.iconTurtle.image = self.iconDown;
    else if( _upLimitIsOn )
        self.iconTurtle.image = self.iconUp;
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
    _originalHeight = self.bounds.size.height;
}

- (void)setUploadString:(NSString *)uploadString
{
    _uploadString = uploadString;
    _labelUL.text = uploadString;
}

- (void)setDownloadString:(NSString *)downloadString
{
    _downloadString = downloadString;
    _labelDL.text = downloadString;
}

@end
