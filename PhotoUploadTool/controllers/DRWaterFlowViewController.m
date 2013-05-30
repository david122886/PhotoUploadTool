//
//  DRWaterFlowViewController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-19.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRWaterFlowViewController.h"

@interface DRWaterFlowViewController ()
{
    int startIndex ;
}
@property(nonatomic,strong) NSMutableDictionary *allDataDic;

@end

@implementation DRWaterFlowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadDatas{
    for (int i = startIndex; i < startIndex +20; i++) {
        DRImageData *imageData = nil;
        switch (i%4) {
            case 0:
                imageData = [DRImageData imageDataWithImageWidth:50 withHeight:70 withURLStr:@"http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg"];
                break;
            case 1:
                imageData = [DRImageData imageDataWithImageWidth:50 withHeight:30 withURLStr:@"http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg"];
                break;
            case 2:
                imageData = [DRImageData imageDataWithImageWidth:50 withHeight:50 withURLStr:@"http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg"];
                break;
            case 3:
                imageData = [DRImageData imageDataWithImageWidth:50 withHeight:100 withURLStr:@"http://ww2.sinaimg.cn/bmiddle/acb53f76gw1e0d3m71gtdj.jpg"];
                break;
        }
        [self.allDataDic setObject:imageData forKey:[NSNumber numberWithInt:i]];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    startIndex = 0;
    DRWaterFlowView *flowView = [[DRWaterFlowView alloc] initWithFrame:self.view.frame];
    flowView.flowViewDelegate = self;
    flowView.tag = 10;
    flowView.backgroundColor = [UIColor grayColor];
    flowView.contentSize = (CGSize){self.view.frame.size.width,100};
    [self.view addSubview:flowView];
    [self loadDatas];
    [flowView reloadData];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark DRWaterFlowViewDelegate
//returen cell
-(DRWaterFlowCell*)flowView:(DRWaterFlowView*)flowView cellForIndex:(int)index{
    DRWaterFlowCell *cell = [flowView dequeueReusableCellWithIdentifier:@"TestCell"];
    if (!cell) {
        cell = [[DRWaterFlowCell alloc]initWithReuseIdentifier:@"TestCell"];
    }
    cell.backgroundColor = [UIColor redColor];
    cell.testLabel.text = [NSString stringWithFormat:@"%d",index];
    return  cell;
}
//return columns
-(int)numberOfFlowViewColumns{
    return 3;
}

//return flowview width
-(int)spaceOfFlowViewCells{
    return 2;
}
//return data of cell include url
-(DRImageData*)flowView:(DRWaterFlowView*)flowView dataForIndex:(int)index{
    return [self.allDataDic objectForKey:[NSNumber numberWithInt:index]];
}
-(int)totalDataNumbers{
    return [self.allDataDic count];
}
//the number of one page
-(int)numberOfFlowViewOnePage{
    return 20;
}

-(void)finishedReloading{
    DRWaterFlowView *flowView = (DRWaterFlowView*)[self.view viewWithTag:10];
    flowView.isloadingData = NO;
    [flowView.refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:flowView];
}

-(void)finishedloading{
    DRWaterFlowView *flowView = (DRWaterFlowView*)[self.view viewWithTag:10];
    flowView.isloadingData = NO;
    [flowView loadData];
}
-(void)flowView:(DRWaterFlowView*)flowView prepareLoadNextPageDataFrom:(int)fromindex to:(int)toIndex;{
    startIndex = fromindex < 0?0:fromindex;
    [self loadDatas];
    NSLog(@"prepareLoadNextPageDataFrom:%d,to:%d",fromindex,toIndex);
    [self performSelector:@selector(finishedloading) withObject:nil afterDelay:2.0];
}

-(void)prepareReloadData:(DRWaterFlowView*)flowView{
    [self.allDataDic removeAllObjects];
    [flowView reloadData];
    [self performSelector:@selector(finishedReloading) withObject:nil afterDelay:2.0];
}
-(void)flowView:(DRWaterFlowView*)flowView didSelectedIndex:(int)selectedIndex{
    NSLog(@"didSelectedIndex:%d",selectedIndex);
}
-(void)flowView:(DRWaterFlowView*)flowView didDeletedIndex:(int)selectedIndex{
    [self.allDataDic removeObjectForKey:[NSNumber numberWithInt:selectedIndex]];
}
#pragma mark --

-(NSMutableDictionary *)allDataDic{
    if (!_allDataDic) {
        _allDataDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _allDataDic;
}
@end
