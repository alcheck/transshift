//
//  PiecesLegendViewController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "PiecesLegendViewController.h"
#import "GlobalConsts.h"

@interface LegendView : UIView

@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger cols;
@property (nonatomic) NSData    *bits;
@property (nonatomic) NSData    *prevbits;
@property (nonatomic) CGFloat   pw;
@property (nonatomic) CGFloat   ph;

@end


@implementation LegendView

- (void)drawRect:(CGRect)rect
{
    if( !_bits )
        return;
    
    
    UIColor *cFilled = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
    UIColor *cEmpty = [UIColor colorWithRed:29.0/255.0 green:151.0/255.0 blue:1.0 alpha:1.0];
    [[UIColor whiteColor] setStroke];
    
    uint8_t *pb = (uint8_t*)_bits.bytes;
    uint8_t *prevb =  NULL;//_prevbits ? (uint8_t*)_prevbits.bytes : NULL;
    
    NSInteger maxc = _count;
    NSInteger shift = 0;
    
    for( NSInteger i = 0; i < maxc; i++ )
    {
        NSInteger row = i / _cols;
        NSInteger col = i % _cols;//- row * _cols;
        
        //NSLog(@"[%i,%i] - %i", row, col, i);
        
        uint8_t c = *pb;
        BOOL filled = ( (c >> shift) & 0x1 ) ? YES : NO;
        BOOL needAnimate = NO;
        if( prevb != NULL )
        {
            uint8_t prevc = *prevb;
            BOOL prevfilled = ( (prevc >> shift) & 0x1 ) ? YES : NO;
            needAnimate = prevfilled != filled;
        }
        
        shift++;
        if( shift > 7 )
        {
            shift = 0;
            pb++;
            
            if( prevb != NULL )
                prevb++;
        }
        
        // draw legend block
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake( col * _pw + 1, row * _ph + 1, _pw - 1, _ph - 1 )];
        filled ? [cFilled setFill] : [cEmpty setFill];
        
        if( needAnimate )
        {
            NSLog(@"Need animate piece");
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.path = path.CGPath;
            layer.fillColor = cEmpty.CGColor;
            layer.lineWidth = 0;
            [self.layer addSublayer:layer];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            anim.duration = 1.0;
            anim.toValue = (__bridge id)(cFilled.CGColor);
            anim.timeOffset = 0.3;
            
            [layer addAnimation:anim forKey:nil];
        }
        else
            [path fill];
    }
}

@end


@interface PiecesLegendViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelPiecesCount;
@property (weak, nonatomic) IBOutlet UILabel *labelPieceSize;
@property (weak, nonatomic) IBOutlet UILabel *labelRowsCount;
@property (weak, nonatomic) IBOutlet UILabel *labelColumnsCount;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PiecesLegendViewController

{
    CGFloat _rows;
    CGFloat _columns;
    
    LegendView *_legendView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setPiecesBitmap:(NSData *)piecesBitmap
{
    if( _legendView.bits )
        _legendView.prevbits = _legendView.bits;
    
    _legendView.bits = piecesBitmap;
    
    [_legendView setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.labelPiecesCount.text = [NSString stringWithFormat: NSLocalizedString(@"Pieces count: %i", nil), _piecesCount];
    self.labelPieceSize.text = [NSString stringWithFormat: NSLocalizedString(@"Piece size: %@", nil), formatByteCount(_pieceSize)];
 
    _columns = 50.0;
    _rows = ceil( _piecesCount / _columns ) ;
    
    self.labelRowsCount.text = [NSString stringWithFormat: NSLocalizedString(@"Rows: %i", nil), (NSInteger)_rows];
    self.labelColumnsCount.text = [NSString stringWithFormat: NSLocalizedString(@"Columns: %i", nil), (NSInteger)_columns];
    
    CGSize  bs = self.scrollView.frame.size;
    CGFloat pw = self.splitViewController ?  (bs.width - 45) / _columns : bs.width/_columns;
    CGFloat ph = pw * 1.4;
    
    self.scrollView.contentSize =  CGSizeMake( pw * _columns, ph * _rows );
    
    _legendView = [[LegendView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height) ];
    _legendView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    _legendView.rows = (NSInteger)_rows;
    _legendView.cols = (NSInteger)_columns;
    _legendView.count = _piecesCount;
    _legendView.pw = pw;
    _legendView.ph = ph;
    
    [self.scrollView addSubview:_legendView];
}

@end
