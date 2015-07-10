//
//  RateLimitTable.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//
//  This class holds rate limits for uploading and downloading
//

#import <Foundation/Foundation.h>

@interface RateLimitTable : NSObject


+ (instancetype)tableWithTitles:(NSArray*)titles andRates:(NSArray*)rates;
- (instancetype)initWithTitles:(NSArray*)titles andRates:(NSArray*)rates;
- (NSString*)titleAtIndex:(int)index;

- (void)updateTableWithRate:(int)rate;

@property(nonatomic)          int        selectedRateIndex;
@property(nonatomic,readonly) NSString  *selectedRateTitle;
@property(nonatomic)          NSString  *tableTitle;
@property(nonatomic,readonly) int        count;
@property(nonatomic,readonly) int        selectedRate;

@end
