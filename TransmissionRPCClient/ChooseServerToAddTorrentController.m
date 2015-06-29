//
//  ChooseServerToAddTorrentController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 29.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ChooseServerToAddTorrentController.h"
#import "RPCServerConfigDB.h"

@interface ChooseServerToAddTorrentController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation ChooseServerToAddTorrentController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Server list";
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [RPCServerConfigDB sharedDB].db.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ((RPCServerConfig*)[RPCServerConfigDB sharedDB].db[row]).name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //NSLog(@"Row selected %i in component %i", row, component);
    _selectedRPCConfig = [RPCServerConfigDB sharedDB].db[row];
    self.detailLabel.text = _selectedRPCConfig.urlString;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end
