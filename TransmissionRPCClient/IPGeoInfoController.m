//
//  IPGeoInfoController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 10.08.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "IPGeoInfoController.h"
#import "GeoIpConnector.h"

#define LABEL_NAME @"freegeoip.net"
#define HOST_NAME  @"http://freegeoip.net"

@interface IPGeoInfoController ()

@end

@implementation IPGeoInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont boldSystemFontOfSize:13.0];
    label.textColor = label.tintColor;
    label.text = LABEL_NAME;
    label.userInteractionEnabled = YES;
    
    [label sizeToFit];
    
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSite)];
    [label addGestureRecognizer:rec];
    
    UIBarButtonItem *lblItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    self.toolbarItems = @[ spacer, lblItem, spacer ];
    
    if( _ipAddress )
        [self getInfo];
}

- (void)goToSite
{
    //NSLog(@"Tapped");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:HOST_NAME]];
}


- (void)getInfo
{
    [self.indicator startAnimating];
    
    GeoIpConnector *geoConnector = [[GeoIpConnector alloc] init];
    
    [geoConnector getInfoForIp:_ipAddress responseHandler:^(NSString *error, NSDictionary *dict)
    {
         [self.indicator stopAnimating];
         if( dict )
         {
             self.labelCountry.text = [dict[@"country_name"] isEqualToString:@""] ? @"-" : dict[@"country_name"];
             self.labelCity.text = [dict[@"city"] isEqualToString:@""] ? @"-" : dict[@"city"];
             self.labelRegion.text = [dict[@"region_name"] isEqualToString:@""] ? @"-": dict[@"region_name"];
         }
         else
         {
             self.labelError.hidden = NO;
             self.icon.image = [UIImage imageNamed:@"iconExclamation36x36"];
             self.icon.image = [self.icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             self.icon.tintColor = [UIColor darkGrayColor];
             self.labelError.text = error;
         }
    }];    
}

@end
