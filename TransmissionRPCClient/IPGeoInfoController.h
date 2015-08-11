//
//  IPGeoInfoController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONROLLER_ID_IPGEOINFO  @"ipGeoInfoController"

@interface IPGeoInfoController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelRegion;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *labelError;

@property (nonatomic) NSString *ipAddress;

@end
