//
//  StatusCategories.h
//  TransmissionRPCClient
//
//  Holds the list of Status Categories

#import <Foundation/Foundation.h>
#import "StatusCategory.h"

@interface StatusCategories : NSObject

@property(nonatomic,readonly) int countOfVisible;

- (StatusCategory*)categoryAtIndex:(int)index;

- (NSArray*)updateForDeleteWithInfos:(TRInfos *)infos;
- (NSArray*)updateForInsertWithInfos:(TRInfos*)infos;

- (void)updateInfos:(TRInfos*)infos;

@end
