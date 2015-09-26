//
//  PiecesLegendViewController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTROLLER_ID_PIECESLEGEND   @"piecesLegendController"

@interface PiecesLegendViewController : UIViewController

@property( nonatomic ) NSInteger  piecesCount;
@property( nonatomic ) long long  pieceSize;
@property( nonatomic ) NSData*    piecesBitmap;
@property( nonatomic ) int        torrentId;

@end
