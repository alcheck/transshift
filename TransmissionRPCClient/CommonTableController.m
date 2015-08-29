//
//  CommonTableController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "CommonTableController.h"
#import "GlobalConsts.h"

@implementation CommonTableController

{
    UILabel*    _errorLabel;
    UILabel*    _infoLabel;
    UILabel*    _footerLabel;
    UILabel*    _headerLabel;
}

/// set nil string to hide error message from top
- (void)setErrorMessage:(NSString *)errorMessage
{
    _errorMessage = errorMessage;
    
    // lazy instantiation
    if( !_errorLabel )
    {
        _errorLabel = [[UILabel  alloc] initWithFrame:CGRectZero];
        _errorLabel.backgroundColor = [UIColor errorColor];
        _errorLabel.textColor = [UIColor whiteColor];
        _errorLabel.numberOfLines = 0;
        _errorLabel.font = [UIFont systemFontOfSize:TABLEHEADER_ERRORLABEL_FONTSIZE];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
    }

    if( errorMessage )
    {
        _errorLabel.text = errorMessage;
        [_errorLabel sizeToFit];
        
        CGRect r = self.tableView.bounds;
        r.size.height = _errorLabel.bounds.size.height + TABLEHEADER_ERRORLABEL_TOPBOTTOMMARGIN;
        
        _errorLabel.bounds = r;
        
        self.tableView.tableHeaderView = _errorLabel;
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    else if( self.tableView.tableHeaderView == _errorLabel )
    {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)setInfoMessage:(NSString *)infoMessage
{
    _infoMessage = infoMessage;
    
    if( !_infoLabel )
    {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.textColor = [UIColor darkGrayColor];
        _infoLabel.font = [UIFont systemFontOfSize:TABLEVIEW_BACKGROUND_MESSAGE_FONTSIZE];
        _infoLabel.numberOfLines = 0;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if( infoMessage )
    {
        _infoLabel.text = infoMessage;
        CGRect r = self.tableView.bounds;
        _infoLabel.frame = r;
        
        self.tableView.backgroundView = _infoLabel;
    }
    else
    {
        self.tableView.backgroundView = nil;
    }
}

- (void)setFooterInfoMessage:(NSString *)footerInfoMessage
{
    _footerInfoMessage = footerInfoMessage;
    
    if( !_footerLabel )
    {
        // show message at bottom
        _footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.textColor = [UIColor grayColor];
        _footerLabel.font = [UIFont systemFontOfSize:TABLEVIEW_FOOTER_MESSAGE_FONTSIZE];
        _footerLabel.numberOfLines = 0;
    }
    
    if( footerInfoMessage )
    {
        NSRange newLineRange = [footerInfoMessage rangeOfString:@"\n"];
        _footerLabel.numberOfLines = newLineRange.length == 0 ? 1 : 0;

        _footerLabel.text = footerInfoMessage;
        [_footerLabel sizeToFit];
        CGRect r = self.tableView.bounds;
        r.size.height = _footerLabel.bounds.size.height + TABLEVIEW_FOOTER_MESSAGE_TOPBOTTOM_MARGINGS;
        self.tableView.tableFooterView = _footerLabel;
    }
    else
        self.tableView.tableFooterView = nil;
}

- (void)setHeaderInfoMessage:(NSString *)headerInfoMessage
{
    _headerInfoMessage = headerInfoMessage;
    
    // show message at bottom
    if( !_headerLabel )
    {
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _headerLabel.textAlignment = NSTextAlignmentCenter;
        _headerLabel.textColor = [UIColor grayColor];
        _headerLabel.font = [UIFont systemFontOfSize:TABLEVIEW_HEADER_MESSAGE_FONTSIZE];
        _headerLabel.numberOfLines = 0;
    }
    
    if( headerInfoMessage )
    {
        NSRange newLineRange = [headerInfoMessage rangeOfString:@"\n"];
        _headerLabel.numberOfLines = newLineRange.length == 0 ? 1 : 0;
        _headerLabel.text = headerInfoMessage;
        [_headerLabel sizeToFit];
        
        CGRect r = self.tableView.bounds;
        r.size.height = _headerLabel.bounds.size.height + 20;
        
        _headerLabel.bounds = r;
        self.tableView.tableHeaderView = _headerLabel;
    }
    else
        self.tableView.tableHeaderView = nil;
}


@end
