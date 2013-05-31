//
//  GridViewController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-14.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()
@property(nonatomic,strong) DRGridView *gridView;
@end

@implementation GridViewController

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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    for (int i = 0; i < 100	; i++) {
        DRGridViewData *data = [[DRGridViewData alloc] init];
        data.imageID = i;
        data.imageURLStr = @"http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg";
        [self.summaryDataArr addObject:data];
        
        [self.scanDataArr addObject:[MWPhoto photoWithURL:[NSURL URLWithString:data.imageURLStr]]];
    }
    self.gridView = [[DRGridView alloc] initWithFrame:(CGRect){0,0,self.view.frame.size.width,self.view.frame.size.height}];
    self.gridView.gridViewDelegate = self;
    self.gridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.gridView];
    [self.gridView reloadData];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.scrollView = nil;
}

#pragma mark DRGridViewDelegate
-(void)prepareAddNewCellData{

}
-(int)numberOfColumns{
    return 3;
}
-(float)heightOfGridViewCell{
    return 100.0;
}
-(int)cacheRowsOfGridView{
    return 10;
}
-(int)numberOfEachPageRows{
    return 20;
}
-(int)numberOfPages{
    return [self.summaryDataArr count]/20 +[self.summaryDataArr count]%20 ==0?0:1;
}
-(int)totalCellCount{
    return [self.summaryDataArr count];
}
-(DRGridViewCell*)gridView:(DRGridView*)gridView cellAtIndex:(int)index{
    DRGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[DRGridViewCell alloc] initWithReuseIdentifier:@"CELL"];
    }
    cell.backgroundColor = [UIColor redColor];
    return cell;
}
-(DRGridViewData*)gridView:(DRGridView*)gridView dataAtIndex:(int)index{
    return [self.summaryDataArr objectAtIndex:index];
}
-(void)prepareReloadData:(DRGridView*)gridView{
    NSLog(@"");
}
-(void)gridView:(DRGridView*)gridView prepareLoadNexPageIndex:(int)pageIndex{
    
}
-(void)gridView:(DRGridView*)gridView didSelectedCellIndex:(int)index{
    // Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    //browser.wantsFullScreenLayout = NO;
    //[browser setInitialPageIndex:2];
    browser.view.frame = [[UIScreen mainScreen] bounds];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.rootController presentModalViewController:nc animated:YES];
    [browser setInitialPageIndex:index-1];
}
-(void)gridView:(DRGridView*)gridView didDeleteCellIndex:(int)index{
    [self.summaryDataArr removeObjectAtIndex:(index)];
    [self.scanDataArr removeObjectAtIndex:index-1];
}
#pragma mark --

#pragma mark - MWPhotoBrowserDelegate

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser backAtIndex:(NSUInteger)index{
    [self.gridView reloadData];
}
-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletedPhotoAtIndex:(NSUInteger)index{
    [self.scanDataArr removeObjectAtIndex:index];
    [self.summaryDataArr removeObjectAtIndex:index+1];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.scanDataArr.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.scanDataArr.count)
        return [self.scanDataArr objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}
#pragma mark --

#pragma mark property
-(NSMutableArray *)summaryDataArr{
    if (!_summaryDataArr) {
        _summaryDataArr = [NSMutableArray arrayWithCapacity:1];
        DRGridViewData *firstData = [[DRGridViewData alloc] init];
        firstData.imageID = 0;
        firstData.imageURLStr = nil;
        [_summaryDataArr addObject:firstData];
    }
    return _summaryDataArr;
}

-(NSMutableArray *)scanDataArr{
    if (!_scanDataArr) {
        _scanDataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _scanDataArr;
}
#pragma mark --
@end
