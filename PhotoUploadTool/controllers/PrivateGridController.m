//
//  PrivateGridController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "PrivateGridController.h"

@interface PrivateGridController ()

@end

@implementation PrivateGridController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isShowModifyPrivatePwdView = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self downloadDataISFirst:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromFinishedUploadImages) name:UPLOAD_IMAGES_POST_RELOADDATAS_PRIVATE object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)receiveNotificationFromFinishedUploadImages{
    self.isFirstDownloadData = NO;
    [self downloadDataISFirst:YES];
}

-(void)prepareReloadData:(DRGridView *)gridView{
    [self downloadDataISFirst:NO];
//    [gridView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setImageData:(NSArray*)imagedataArr isFirst:(BOOL)isFirst{
    [self.summaryDataArr removeAllObjects];
    [self.scanDataArr removeAllObjects];
    int imageIndex = 0;
    for (DRImageObj *obj in imagedataArr) {
        DRGridViewData *data = [[DRGridViewData alloc] init];
        data.imageID = imageIndex;
        data.imageDataID = obj.imageDataID;
        data.imageURLStr = obj.smallImageURLStr;
        if (obj.isCoverImage) {
            self.gridView.coverImageIndex = imageIndex+1;
        }
        [self.summaryDataArr addObject:data];
        //        http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:obj.bigImageURLStr]];
        photo.caption = obj.describle;
        photo.imageDataID = obj.imageDataID;
        [self.scanDataArr addObject:photo];
        imageIndex++;
    }
    [self.gridView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_DOWNLOADDATA_NOTIFICATION_OK object:nil];
}

-(void)coverImageNotification:(NSNotification*)note{
    if ([[note.userInfo objectForKey:@"catory"]  isEqualToString:@"public"]) {
        self.gridView.coverImageIndex = -1;
    }
}
-(void)downloadDataISFirst:(BOOL)isFirst{
    if (isFirst) {
        if (self.isFirstDownloadData) {
            if (self.gridView.coverImageIndex == -1) {
                [self.gridView reloadData];
            }
            return;
        }else{
            self.isFirstDownloadData = isFirst;
        }
    }
    PrivateGridController __weak *weakPublicGridCtr = self;
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
    [DRImageTool downLoadDRImageDataWithUserID:appDelegate.user.userId withType:PRIVATE_IMAGEDATA withSuccess:^(NSArray *drImageDataArr) {
        PrivateGridController *pubCtr = weakPublicGridCtr;
        if (pubCtr) {
            [pubCtr stopRefreshView];
            [pubCtr setImageData:drImageDataArr isFirst:isFirst];
        }
        
    } withFailure:^(NSError *error) {
        PrivateGridController *pubCtr = weakPublicGridCtr;
        if (pubCtr) {
            [pubCtr alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            [pubCtr stopRefreshView];
            [MBProgressHUD hideHUDForView:pubCtr.view animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_DOWNLOADDATA_NOTIFICATION_OK object:nil];
        }
        
    }];
}

-(void)gridView:(DRGridView*)gridView modifyPrivatePwd:(UIButton*)_modifyBt{

}
@end
