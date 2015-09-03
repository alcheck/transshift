//
//  MagnetURLViewController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 03.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_MAGNETURL @"magnetURLViewController"

@interface MagnetURLViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textMagnetLink;
@property (nonatomic) NSString *urlString;

@end
