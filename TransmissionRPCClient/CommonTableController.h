//
//  CommonTableController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTableController : UITableViewController

/// Table Header info message (UILabel text)
@property(nonatomic) NSString* errorMessage;

/// Table background view message (UILabel text)
@property(nonatomic) NSString* infoMessage;

/// Table footer info message
@property(nonatomic) NSString* footerInfoMessage;

/// Table header info message
@property(nonatomic) NSString* headerInfoMessage;

@end
