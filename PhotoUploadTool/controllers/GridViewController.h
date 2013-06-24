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
#import "AGImagePickerController.h"
#import "UPLoadImageController.h"
#import "DRImageTool.h"
#import "AppDelegate.h"
#import "DRImageObj.h"
@protocol GridViewControllerDelegate;
@interface GridViewController : UIViewController<DRGridViewDelegate,MWPhotoBrowserDelegate>
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) NSMutableArray *summaryDataArr;
@property(nonatomic,strong) NSMutableArray *scanDataArr;
@property(nonatomic,strong) UIViewController *rootController;
@property(nonatomic,strong) UPLoadImageController *uploadCtr;
@property(nonatomic,strong) DRGridView *gridView;
@property(nonatomic,assign) BOOL isShowModifyPrivatePwdView;
@property(nonatomic,assign) BOOL isFirstDownloadData;
@property(nonatomic,assign) CGRect contentRect;
-(void)alertErrorMessage:(NSString*)mes;
-(void)stopRefreshView;
-(id)initWithContentFrame:(CGRect)frame;
@end

@protocol GridViewControllerDelegate <NSObject>

@end