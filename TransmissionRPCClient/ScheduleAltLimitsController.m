//
//  ScheduleAltLimitsController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 26.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "ScheduleAltLimitsController.h"

#define CELL_ID_DAY @"tableViewCell"

@interface ScheduleAltLimitsController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *dateTo;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateFrom;
@property (weak, nonatomic) IBOutlet UITableView  *tableDays;

@property (nonatomic) NSArray        *dayNums;
@property (nonatomic) NSMutableArray *selectedDays;

@end

@implementation ScheduleAltLimitsController

{
    NSArray             *_days;
    //NSArray             *_dayNums;
    //NSMutableArray      *_selectedDays;
    
    NSDate              *_dateBegin;
    NSDate              *_dateEnd;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableDays.dataSource = self;
    _tableDays.delegate = self;
    
    _days = @[ NSLocalizedString( @"On Mondays", @"" ),
               NSLocalizedString( @"On Tuesdays", @"" ),
               NSLocalizedString( @"On Wednesdays", @"" ),
               NSLocalizedString( @"On Thursdays", @"" ),
               NSLocalizedString( @"On Fridays", @"" ),
               NSLocalizedString( @"On Saturdays", @"" ),
               NSLocalizedString( @"On Sundays", @"" )
              ];
    
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

// lazy instntiation
- (NSMutableArray *)selectedDays
{
    if( !_selectedDays )
        //_dayNums = @[ @(2), @(4), @(8), @(16), @(32), @(64), @(1) ];
        _selectedDays = [NSMutableArray arrayWithArray: @[ @(NO), @(NO), @(NO), @(NO), @(NO), @(NO), @(NO) ] ];
    
    return _selectedDays;
}

- (NSArray *)dayNums
{
    if ( !_dayNums )
        _dayNums = @[ @(2), @(4), @(8), @(16), @(32), @(64), @(1) ];
    
    return _dayNums;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( _dateBegin && _dateEnd )
    {
        _dateFrom.date = _dateBegin;
        _dateTo.date = _dateEnd;
        
        [self.tableDays reloadData];
    }
}

- (void)setDaysMask:(int)daysMask
{
    for( NSUInteger i = 0; i < self.dayNums.count; i++ )
    {
        int n = [self.dayNums[i] intValue];
    
        self.selectedDays[i] = ( daysMask & n ) ? @(YES) : @(NO);
    }
}

- (int)daysMask
{
    int mask = 0;
    
    for( NSUInteger i = 0; i < self.dayNums.count; i++ )
    {
        int n = [self.dayNums[i] intValue];
        
        if( [self.selectedDays[i] boolValue] )
            mask |= n;
    }
    
    return mask;
}

- (void)setTimeBegin:(int)timeBegin
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *cp = [c components:NSUIntegerMax fromDate:[NSDate date]];
    cp.hour = timeBegin / 60;
    cp.minute = timeBegin % 60;
    
    _dateBegin = [c dateFromComponents:cp];
    
    //[_dateFrom setDate:[c dateFromComponents:cp] animated:YES];
}

- (int)timeBegin
{
    NSDate *dt = _dateFrom.date;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *c = [cal components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:dt];
    
    return (int)(c.hour * 60 + c.minute);
}

- (void)setTimeEnd:(int)timeEnd
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *cp = [c components:NSUIntegerMax fromDate:[NSDate date]];
    cp.hour = timeEnd / 60;
    cp.minute = timeEnd % 60;
    
    _dateEnd = [c dateFromComponents:cp];
    //[_dateTo setDate:[c dateFromComponents:cp] animated:YES];
}

- (int)timeEnd
{
    NSDate *dt = _dateTo.date;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *c = [cal components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:dt];
    
    return (int)(c.hour * 60 + c.minute);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _days.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString( @"Select days", @"" );
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL selected = [self.selectedDays[indexPath.row] boolValue];
    self.selectedDays[indexPath.row] = @(!selected);
    
    [tableView reloadData];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_DAY forIndexPath:indexPath];
    
    cell.textLabel.text = _days[indexPath.row];
    cell.accessoryType = [self.selectedDays[indexPath.row] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (IBAction)timeFromChanged:(UIDatePicker *)sender
{
    NSDate *dt0 = sender.date;
    NSDate *dt1 = _dateTo.date;
    
    NSComparisonResult res = [dt0 compare:dt1];
    if( res == NSOrderedDescending || res == NSOrderedSame )
    {
        NSDate *dt = [NSDate dateWithTimeInterval:(15 * 60) sinceDate:dt0];
        [_dateTo setDate:dt animated:YES];
    }
}

- (IBAction)timeToChanged:(UIDatePicker *)sender
{
    NSDate *dt0 = sender.date;
    NSDate *dt1 = _dateFrom.date;
    
    NSComparisonResult res = [dt0 compare:dt1];
    if( res == NSOrderedAscending || res == NSOrderedSame )
    {
        NSDate *dt = [NSDate dateWithTimeInterval:-(15 * 60) sinceDate:dt0];
        [_dateFrom setDate:dt animated:YES];
    }
}

@end
