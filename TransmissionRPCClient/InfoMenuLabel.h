//
//  InfoMenuLabel.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoMenuLabelDelegate <NSObject>

@optional - (void)InfoMenuLabelSetNewName:(NSString *)newname;

@end

@interface InfoMenuLabel : UILabel

@property( weak, nonatomic ) id<InfoMenuLabelDelegate> delegate;

- (void)customMenuAction:(id)sender;

@end
