//
//  RateLimitTable.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "RateLimitTable.h"

@implementation RateLimitTable

{
    NSMutableArray *_titles;
    NSMutableArray *_rates;
}

+ (instancetype)tableWithTitles:(NSArray *)titles andRates:(NSArray *)rates
{
    RateLimitTable *table = [[RateLimitTable alloc] initWithTitles:titles andRates:rates];
    return  table;
}

- (instancetype)initWithTitles:(NSArray *)titles andRates:(NSArray *)rates
{
    self = [super init];
    
    if( self )
    {
        if( titles.count != rates.count )
            @throw [NSException exceptionWithName:@"RateLimitTable"
                                           reason:@"initWithTitles: titles and rates have diffrent items count"
                                         userInfo:nil];
        
        if( titles.count == 0 )
            @throw [NSException exceptionWithName:@"RateLimitTable"
                                           reason:@"initWithTitles: titles and rates at least have to conain one element"
                                         userInfo:nil];
        
        // copy elements
        _titles = [NSMutableArray arrayWithArray:titles];
        _rates = [NSMutableArray arrayWithArray:rates];
        
        // by default, selected top rate (unlimited)
        _selectedRateIndex = 0;
    }
    
    return self;
}

- (int)selectedRate
{
    return [(NSNumber*)_rates[_selectedRateIndex] intValue];
}

- (NSString *)selectedRateTitle
{
    return _titles[_selectedRateIndex];
}

- (int)count
{
    return (int)_rates.count;
}

- (NSString *)titleAtIndex:(int)index
{
    return _titles[index];
}

// update table with new value @rate
// if table does not have this rate, table will be
// updated
- (void)updateTableWithRate:(int)rate
{
    _selectedRateIndex = 0;
    
    BOOL needToUpdate = YES;
    int  insertIndex = (int)_rates.count;
    
    int prevRate = 0;
    for( int i = 1; i < _rates.count; i++ ) // start from 1 - skip the first element
    {
        int tableRate = [(NSNumber*)_rates[i] intValue];
        
        // table already has this rate, exit
        if( tableRate == rate )
        {
            needToUpdate = NO;
            _selectedRateIndex = i;
            break;
        }
        
        // we should place new rate
        // between neighboor's position
        if( rate > prevRate &&  rate < tableRate )
        {
            insertIndex = i;
            break;
        }
        
        prevRate = tableRate;
    }
    
    // table does not have this rate
    // add this new rate in proper position
    if( needToUpdate )
    {
        NSString *title = [NSString stringWithFormat: NSLocalizedString(@"%i KB/s", @"RateLimitTable added title"), rate];
        
        if( insertIndex >= _rates.count )
        {
            [_rates  addObject:@(rate)];
            [_titles addObject:title];
        }
        else
        {
            [_rates  insertObject:@(rate) atIndex: insertIndex];
            [_titles insertObject:title atIndex: insertIndex];
        }
        
        _selectedRateIndex = insertIndex;
    }
}

@end
