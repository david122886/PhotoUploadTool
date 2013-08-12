//
//  MWPhotoBrowserTabBarView.m
//  PhotoUploadTool
//
//  Created by david on 13-5-31.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "MWPhotoBrowserTabBarView.h"

@implementation MWPhotoBrowserTabBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.leftBt = [[UIButton alloc] initWithFrame:(CGRect){7,7,30,30}];
        self.leftBt.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin ;
        [self.leftBt setBackgroundImage:[UIImage imageNamed:@"scan_back.png"] forState:UIControlStateNormal];
        self.rightBt = [[UIButton alloc] initWithFrame:(CGRect){self.frame.size.width - 40,7,30,30}];
        self.rightBt.autoresizingMask = UIViewAutoresizingFlexibleRightMargin ;
        [self.rightBt setBackgroundImage:[UIImage imageNamed:@"scan_delete.png"] forState:UIControlStateNormal];
        self.middleLabel = [[UILabel alloc] initWithFrame:(CGRect){50,10,self.frame.size.width - 50*2,self.frame.size.height - 20}];
        self.leftBt.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  | UIViewAutoresizingFlexibleRightMargin;
        self.middleLabel.backgroundColor = [UIColor clearColor];
        [self.middleLabel setTextColor:[UIColor whiteColor]];
        self.middleLabel.textAlignment = UITextAlignmentCenter;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        self.middleBt = [[UIButton alloc] initWithFrame:(CGRect){self.frame.size.width - 80,7,30,30}];
        self.middleBt.autoresizingMask = UIViewAutoresizingFlexibleRightMargin ;
        [self.middleBt setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
//        [self addSubview:self.leftBt];
        [self addSubview:self.middleBt];
        [self addSubview:self.rightBt];
        [self addSubview:self.middleLabel];
        
    }
    return self;
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
