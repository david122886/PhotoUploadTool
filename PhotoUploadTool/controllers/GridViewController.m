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
@property(nonatomic,strong) NSMutableArray *dataArr;
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
    for (int i = 0; i < 1000; i++) {
        DRGridViewData *data = [[DRGridViewData alloc] init];
        data.imageID = i;
        data.imageURLStr = @"http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg";
        [self.dataArr addObject:data];
    }
    self.gridView = [[DRGridView alloc] initWithFrame:(CGRect){0,0,self.view.frame.size.width,self.view.frame.size.height}];
    self.gridView.gridViewDelegate = self;
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
    return [self.dataArr count]/20 +[self.dataArr count]%20 ==0?0:1;
}
-(int)totalCellCount{
    return [self.dataArr count];
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
    return [self.dataArr objectAtIndex:index];
}
-(void)prepareReloadData:(DRGridView*)gridView{
    NSLog(@"");
}
-(void)gridView:(DRGridView*)gridView prepareLoadNexPageIndex:(int)pageIndex{
    
}
-(void)gridView:(DRGridView*)gridView didSelectedCellIndex:(int)index{
    
}
-(void)gridView:(DRGridView*)gridView didDeleteCellIndex:(int)index{
    [self.dataArr removeObjectAtIndex:index];
}
#pragma mark --

#pragma mark property
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:1];
        DRGridViewData *firstData = [[DRGridViewData alloc] init];
        firstData.imageID = 0;
        firstData.imageURLStr = nil;
        [_dataArr addObject:firstData];
    }
    return _dataArr;
}
#pragma mark --
@end
