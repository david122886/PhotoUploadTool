//
//  PrivatePwdmodifyView.m
//  PhotoUploadTool
//
//  Created by david on 13-6-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "PrivatePwdmodifyView.h"
#import <QuartzCore/QuartzCore.h>
#define MODIFYVIEW_SPACE 2
#define MODIFYVIEW_BT_WIDTH 60
#define MODIFYVIEW_BT_HEIGHT 30
#define MODIFYVIEW_ACTIVITY_HEIGHT 20
@implementation PrivatePwdmodifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pwdLabel = [[UILabel alloc] init];
        self.pwdLabel.backgroundColor = [UIColor clearColor];
        self.pwdLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.pwdLabel setTextColor:[UIColor whiteColor]];
        [self.pwdLabel setFont:[UIFont systemFontOfSize:10]];
        [self.pwdLabel setTextAlignment:NSTextAlignmentLeft];
        self.modifyPwdBt = [[UIButton alloc] initWithFrame:CGRectZero];
        
//        [self.modifyPwdBt setImage:[UIImage imageNamed:@"ic_mail.png"] forState:UIControlStateNormal];
        [self.modifyPwdBt setBackgroundColor:[UIColor colorWithRed:0.2 green:0.3 blue:0.5 alpha:0.6]];
        self.modifyPwdBt.layer.cornerRadius = 5;
//        [self.modifyPwdBt setContentEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        [self.modifyPwdBt setTitleEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        [self.modifyPwdBt.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [self.modifyPwdBt setTitle:@"修改密码" forState:UIControlStateNormal];
        [self.modifyPwdBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.7 alpha:0.4];
        [self addSubview:self.pwdLabel];
        [self addSubview:self.modifyPwdBt];
        [self addSubview:self.activityView];
//        [self.activityView startAnimating];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.pwdLabel.frame = (CGRect){MODIFYVIEW_SPACE,MODIFYVIEW_SPACE,self.frame.size.width - MODIFYVIEW_SPACE*3 - MODIFYVIEW_BT_WIDTH,self.frame.size.height - MODIFYVIEW_SPACE*2};
    self.modifyPwdBt.frame = (CGRect){self.frame.size.width - MODIFYVIEW_SPACE - MODIFYVIEW_BT_WIDTH,MODIFYVIEW_SPACE,MODIFYVIEW_BT_WIDTH,self.frame.size.height - MODIFYVIEW_SPACE*2};
    self.activityView.frame = (CGRect){self.modifyPwdBt.frame.origin.x - MODIFYVIEW_ACTIVITY_HEIGHT - MODIFYVIEW_SPACE*2,MODIFYVIEW_SPACE*2,MODIFYVIEW_ACTIVITY_HEIGHT,MODIFYVIEW_ACTIVITY_HEIGHT};
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
