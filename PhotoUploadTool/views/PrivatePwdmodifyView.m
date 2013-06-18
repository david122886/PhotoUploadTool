//
//  PrivatePwdmodifyView.m
//  PhotoUploadTool
//
//  Created by david on 13-6-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "PrivatePwdmodifyView.h"
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
        [self.pwdLabel setTextColor:[UIColor blackColor]];
        [self.pwdLabel setFont:[UIFont systemFontOfSize:10]];
        [self.pwdLabel setTextAlignment:NSTextAlignmentLeft];
        self.modifyPwdBt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.modifyPwdBt setTitle:@"修改密码" forState:UIControlStateNormal];
        [self.modifyPwdBt setTitleEdgeInsets:UIEdgeInsetsMake(5, 8, 5, 8)];
        [self.modifyPwdBt.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.modifyPwdBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
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
