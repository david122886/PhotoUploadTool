//
//  PublicGridController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "PublicGridController.h"
#import "DRTabBarController.h"
@interface PublicGridController ()

@end

@implementation PublicGridController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadDataISFirst:YES];
}

-(void)prepareReloadData:(DRGridView *)gridView{
    [self.summaryDataArr removeAllObjects];
    [self.scanDataArr removeAllObjects];
    [self downloadDataISFirst:NO];
    [gridView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setImageData:(NSArray*)imagedataArr isFirst:(BOOL)isFirst{
    int imageIndex = 0;
    for (DRImageObj *obj in imagedataArr) {
        DRGridViewData *data = [[DRGridViewData alloc] init];
        data.imageID = imageIndex;
        data.imageURLStr = obj.smallImageURLStr;
        [self.summaryDataArr addObject:data];
//        http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg
        [self.scanDataArr addObject:[MWPhoto photoWithURL:[NSURL URLWithString:obj.bigImageURLStr]]];
        imageIndex++;
    }
    [self.gridView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_DOWNLOADDATA_NOTIFICATION_OK object:nil];
}

-(void)downloadDataISFirst:(BOOL)isFirst{
    PublicGridController __weak *weakPublicGridCtr = self;
    __block BOOL first = isFirst;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.user || !appDelegate.user.userId) {
        [self stopRefreshView];
        return;
    }
    if (isFirst) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.gridView.isloadingData = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_DOWNLOADDATA_NOTIFICATION object:nil];
    [self.gridView.refreshView refreshLastUpdatedDate];
    [DRImageTool downLoadDRImageDataWithUserID:appDelegate.user.userId withType:PUBLIC_IMAGEDATA withSuccess:^(NSArray *drImageDataArr) {
        PublicGridController *pubCtr = weakPublicGridCtr;
        [pubCtr stopRefreshView];
        [pubCtr setImageData:drImageDataArr isFirst:first];
    } withFailure:^(NSError *error) {
        PublicGridController *pubCtr = weakPublicGridCtr;
        [pubCtr alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        [pubCtr stopRefreshView];
        [MBProgressHUD hideHUDForView:pubCtr.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_DOWNLOADDATA_NOTIFICATION_OK object:nil];
    }];
}


@end
