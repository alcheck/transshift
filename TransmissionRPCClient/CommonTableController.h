//
//  CommonTableController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTableController : UITableViewController

@property(nonatomic) NSString* errorMessage;
@property(nonatomic) NSString* infoMessage;
@property(nonatomic) NSString* footerInfoMessage;
@property(nonatomic) NSString* headerInfoMessage;

@end
