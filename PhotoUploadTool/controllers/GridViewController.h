//
//  GridViewController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-14.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGridView.h"
@protocol GridViewControllerDelegate;
@interface GridViewController : UIViewController<DRGridViewDelegate>
@property(nonatomic,strong) UIScrollView *scrollView;
@end

@protocol GridViewControllerDelegate <NSObject>

@end