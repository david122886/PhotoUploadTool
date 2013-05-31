//
//  GridViewController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-14.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGridView.h"
#import "MWPhotoBrowser.h"
@protocol GridViewControllerDelegate;
@interface GridViewController : UIViewController<DRGridViewDelegate,MWPhotoBrowserDelegate>
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) NSMutableArray *summaryDataArr;
@property(nonatomic,strong) NSMutableArray *scanDataArr;
@property(nonatomic,strong) UIViewController *rootController;
@end

@protocol GridViewControllerDelegate <NSObject>

@end