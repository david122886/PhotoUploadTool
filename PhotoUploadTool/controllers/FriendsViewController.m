//
//  FriendsViewController.m
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//


#pragma mark QBGridViewTest ///////


#import "FriendsViewController.h"
#import "LoginInController.h"
#import "DRTabBarController.h"
#if QBGridViewTest

#define GRIDVIEW_SPACE 5.0
#define GRIDVIEW_CELL_HEIGHT 200.0
#define GRIDVIEW_CELL_WIDTH 150.0
#define GRIDVIEW_COLOUMN_COUNT  2
@interface FriendsViewController ()
@property (nonatomic,strong) NSMutableArray *friendsArr;
@property (nonatomic,strong) GridView *gridView;
@property (nonatomic,strong)  FriendPhotoViewController *friendPhotoCtr;
@property (nonatomic,assign) int pageCount;
@end

@implementation FriendsViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    [self.bottomRightBt setBackgroundImage:[UIImage imageNamed:@"tabbarbg.png"] forState:UIControlStateHighlighted];
    [self.topRightBt setBackgroundImage:[UIImage imageNamed:@"tabbarbg.png"] forState:UIControlStateHighlighted];
    self.gridView.gridDelegate = self;
    [self.topRightBt setTitle:nil forState:UIControlStateNormal];
//    self.gridView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.gridView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateSuccess:) name:LOCATE_POSITION_SUCCESS object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateFailure:) name:LOCATE_POSITION_FAILURE object:self];

    NSNumber *locatePosionType = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATE_POSITION_TYPE];
    if (!locatePosionType || [locatePosionType boolValue] ==YES) {
        MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progress.labelText = @"正在获取当前地理位置";
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate setAutoLocationForController:self];
    }else{
        [self locatePosition];
    }
	// Do any additional setup after loading the view.
}

-(void)locateSuccess:(NSNotification*)note{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self locatePosition];
}

-(void)locateFailure:(NSNotification*)note{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([[note.userInfo objectForKey:@"error"] isEqualToString:@"系统禁用定位服务"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[note.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:@"手动设置" otherButtonTitles:nil];
        [alert show];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    self.notificationTipLabel.layer.cornerRadius = 3;
    if ([UIApplication sharedApplication].applicationIconBadgeNumber != 0) {
        self.notificationTipLabel.backgroundColor = [UIColor redColor];
        NSString *tip = [NSString stringWithFormat:@"%d",[UIApplication sharedApplication].applicationIconBadgeNumber];
        CGRect rect = self.notificationTipLabel.frame;
        CGSize detailSize = [tip sizeWithFont:self.notificationTipLabel.font constrainedToSize:CGSizeMake(MAXFLOAT,rect.size.height) lineBreakMode:UILineBreakModeWordWrap];
        self.notificationTipLabel.frame = (CGRect){rect.origin.x,rect.origin.y,detailSize.width+2,rect.size.height};
        self.notificationTipLabel.text = tip;
    }else{
        self.notificationTipLabel.text = @"";
        self.notificationTipLabel.backgroundColor = [UIColor clearColor];
    }    [super viewWillAppear:animated];
    [self.gridView reloadGrid];
}

-(void)locatePosition{
    AppDelegate  *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSNumber *locatePosionType = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATE_POSITION_TYPE];
    if ([locatePosionType boolValue] == YES) {
        [self.topRightBt setTitle:appDelegate.city forState:UIControlStateNormal];
        [self dowloadFriendsDataWithCityName:appDelegate.city isPullScrollViewRefreshData:NO withPageIndex:0];
    }else{
        [self.topRightBt setUserInteractionEnabled:NO];
        TSLocateView *locateView = [[TSLocateView alloc] initWithTitle:@"定位城市" delegate:self];
        [locateView showInView:self.view];
    }
    return;
    
    
    AppDelegate __weak *weakDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FriendsViewController __weak *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LocatePositionManager locatePositionSuccess:^(NSString *locatitonName, CLLocationCoordinate2D locationg) {
        if (weakSelf) {
            NSString *city = nil;
            if (locatitonName) {
                city = [locatitonName stringByReplacingOccurrencesOfString:@"市" withString:@""];
            }
            weakDelegate.city = city;
            [weakSelf.topRightBt setTitle:city forState:UIControlStateNormal];
            if (city != nil) {
                [LocatePositionManager stopUpdate];
            }
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf dowloadFriendsDataWithCityName:city isPullScrollViewRefreshData:NO withPageIndex:0];
            
        }
        
    } failure:^(NSError *error) {
        if (weakSelf) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [self.topRightBt setTitle:@"所有城市" forState:UIControlStateNormal];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error.userInfo objectForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
    }];
}


-(void)dowloadFriendsDataWithCityName:(NSString*)city isPullScrollViewRefreshData:(BOOL)isPullScrollView withPageIndex:(int)pageIndex{
    if (!isPullScrollView) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    if (!city || [city isEqualToString:@""]) {
        city = @"上海";
    }
    FriendsViewController __weak *weakSelf = self;
    [FriendObjDao downloadFriendObjsWithCityName:city withPageIndex:pageIndex withSuccess:^(NSDictionary *friendsDic) {
        if (weakSelf) {
            NSArray *friendsArr = [friendsDic objectForKey:@"users"];
            weakSelf.pageCount = [[friendsDic objectForKey:@"pageCount"] intValue];
            NSString *cityName = [friendsDic objectForKey:@"city"];
            if (isPullScrollView) {
                if (weakSelf.gridView.loadDataType == GRIDVIEW_RELOADDATA) {
                    weakSelf.gridView.currentPageIndex = 0;
                    [weakSelf.friendsArr removeAllObjects];
                    if ([cityName isEqualToString:@"error"]) {
                        if (![city isEqualToString:@"所有城市"]) {
                            [weakSelf alertErrorMessage:[NSString stringWithFormat:@"%@无同城用户",city]];
                        }
                        
                        [weakSelf.topRightBt setTitle:@"所有城市" forState:UIControlStateNormal];
                    }
                }else{
                    
                    if ([cityName isEqualToString:@"error"]) {
                        
                        if (![city isEqualToString:@"所有城市"]) {
                            weakSelf.gridView.currentPageIndex = 0;
                            [weakSelf.friendsArr removeAllObjects];
                            [weakSelf alertErrorMessage:[NSString stringWithFormat:@"%@无同城用户",city]];
                        }else{
                            weakSelf.gridView.currentPageIndex = pageIndex;
                        }
                        [weakSelf.topRightBt setTitle:@"所有城市" forState:UIControlStateNormal];
                    }else
                    if ([cityName isEqualToString:@"success"]){
                        weakSelf.gridView.currentPageIndex = pageIndex;
                    }
                }
            }else{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                weakSelf.gridView.currentPageIndex = 0;
                [weakSelf.friendsArr removeAllObjects];
                if ([cityName isEqualToString:@"error"]) {
                    [weakSelf alertErrorMessage:[NSString stringWithFormat:@"%@无同城用户",city]];
                    [weakSelf.topRightBt setTitle:@"所有城市" forState:UIControlStateNormal];
                }
            }
            weakSelf.gridView.isLoading = NO;
            [weakSelf.gridView.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:weakSelf.gridView];
            [weakSelf.gridView.refreshTailerView egoRefreshScrollViewDataSourceDidFinishedLoading:weakSelf.gridView];

            [weakSelf.friendsArr addObjectsFromArray:friendsArr];
            [weakSelf.gridView reloadGrid];
        }
    } withfailure:^(NSError *error) {
        if (weakSelf) {
            [weakSelf alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            if (!isPullScrollView) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
        }
    }];
}


-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBottomLeftBt:nil];
    [self setBottomRightBt:nil];
    [self setTopRightBt:nil];
    [self setContentView:nil];
    [self setNotificationTipLabel:nil];
    [super viewDidUnload];
}
- (IBAction)topRightClicked:(UIButton *)sender {
    [self.topRightBt setUserInteractionEnabled:NO];
    TSLocateView *locateView = [[TSLocateView alloc] initWithTitle:@"定位城市" delegate:self];
    [locateView showInView:self.view];
}

- (IBAction)bottomLeftClicked:(UIButton *)sender {
}

- (IBAction)bottomRightClicked:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
    if (appDelegate.user) {
        DRTabBarController *tabController = [story instantiateViewControllerWithIdentifier:@"DRTabBarController"];
        [self.navigationController pushViewController:tabController animated:YES];
    }else{
        LoginInController *loginCtr = [story instantiateViewControllerWithIdentifier:@"LoginInController"];
        [self.navigationController pushViewController:loginCtr animated:YES];
    }
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self topRightClicked:nil];
}
#pragma mark -- 


#pragma mark GridCellDelegate
/** Required methods **/
- (NSInteger)numberOfRowsInGridView:(GridView*)gridView {
    int rowCount = [self.friendsArr count]/GRIDVIEW_COLOUMN_COUNT + ([self.friendsArr count]%GRIDVIEW_COLOUMN_COUNT > 0? 1 : 0);
	return rowCount;
}

-(int)numberOfPageCount{
    return self.pageCount;
}
-(unsigned int)numberOfCellsInGridView:(GridView *)gridView{
    return [self.friendsArr count];
}
- (NSInteger)numberOfColumnsInGridView:(GridView*)gridView {
	return GRIDVIEW_COLOUMN_COUNT;
}
- (GridCell *)gridView:(GridView*)gridView cellForGridAtGridIndex:(GridIndex)index {
	
	static NSString * cellIdentifier = @"CellIdentifier";
	
	GridCell * cell = [gridView dequeueReusableGridCellWithIdentifier:cellIdentifier];
	if (cell==nil) {
		cell = [[GridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseGridIdentifier:cellIdentifier];
	}
    NSLog(@"row:%d,column:%d,index:%d",index.row,index.column,index.row*2+index.column);
    FriendObj *friend = [self.friendsArr objectAtIndex:index.row*2+index.column];
//    [cell.cellButton setTitle:[NSString stringWithFormat:@"row:%d,column:%d,index:%d",index.row,index.column,index.row*2+index.column] forState:UIControlStateNormal];
    [cell.cellimageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:friend.webURL]] placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:nil  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
	return cell;
}

/** Optional methods **/

- (CGFloat)heightForCellInGridView:(GridView*)gridView {
	return GRIDVIEW_CELL_HEIGHT;
}
- (CGFloat)widthForCellInGridView:(GridView*)gridView {
	return GRIDVIEW_CELL_WIDTH;
}
- (CGFloat)horizontalSpacingForGrid:(GridView*)gridView {
	return GRIDVIEW_SPACE;
}
- (CGFloat)verticalSpacingForGrid:(GridView*)gridView {
	return GRIDVIEW_SPACE;
}
- (void)gridView:(GridView*)gridView cellDidSelectedAtGridIndex:(GridIndex)index {
    NSLog(@"row:%d,column:%d,index:%d",index.row,index.column,index.row*2+index.column);
    FriendObj *friend = [self.friendsArr objectAtIndex:index.row*2+index.column];
    self.friendPhotoCtr.friendID = friend.friendID;
    self.friendPhotoCtr.isLocked = YES;
    [self presentModalViewController:self.friendPhotoCtr animated:YES];
    [self.friendPhotoCtr downloadFriendsPhotosWithImageType:PUBLIC_IMAGEDATA];
}

- (void)gridViewReloadData:(GridView*)gridView{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        gridView.isLoading = NO;
        [gridView.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:gridView];
    });
    [self dowloadFriendsDataWithCityName:self.topRightBt.titleLabel.text isPullScrollViewRefreshData:YES withPageIndex:0];
}
-(void)gridView:(GridView *)gridView loadMoreDataAtPageIndex:(int)pageIndex{
    [self dowloadFriendsDataWithCityName:self.topRightBt.titleLabel.text isPullScrollViewRefreshData:YES withPageIndex:pageIndex];
}
#pragma mark --

#pragma mark UIActionSheetDelete
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        TSLocateView *locateView = (TSLocateView *)actionSheet;
        TSLocation *location = locateView.locate;
        if ([location.city isEqualToString:self.topRightBt.titleLabel.text]) {
            self.gridView.currentPageIndex = 0;
        }
        [self.topRightBt setTitle:location.city forState:UIControlStateNormal];
        
        [self dowloadFriendsDataWithCityName:location.city isPullScrollViewRefreshData:NO withPageIndex:0];
    }
    [self.topRightBt setUserInteractionEnabled:YES];
}
#pragma mark --

#pragma mark property
-(NSMutableArray *)friendsArr{
    if (!_friendsArr) {
        _friendsArr = [NSMutableArray array];
    }
    return _friendsArr;
}

-(GridView *)gridView{
    if (!_gridView) {
        _gridView = [[GridView alloc] initWithFrame:(CGRect){0,0,self.contentView.frame.size} isLoadMoreDataAble:YES];
        _gridView.isLoading = NO;
    }
    return _gridView;
}

-(FriendPhotoViewController *)friendPhotoCtr{
    if (!_friendPhotoCtr) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
        _friendPhotoCtr = [story instantiateViewControllerWithIdentifier:@"FriendPhotoViewController"];
    }
    return _friendPhotoCtr;
}
#pragma mark --

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

#else


#pragma mark DRGridViewTest ///////

#import "DRImageTool.h"
#import "DRGridView.h"
#import "FriendObj.h"
#define GRIDVIEW_SPACE 5.0
#define GRIDVIEW_CELL_HEIGHT 170.0
#define GRIDVIEW_CELL_WIDTH 150.0
#define GRIDVIEW_COLOUMN_COUNT  2
@interface FriendsViewController ()
@property (nonatomic,strong) NSMutableArray *friendsArr;
@property (nonatomic,strong) DRGridView *gridView;
@end

@implementation FriendsViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    [self.bottomRightBt setBackgroundImage:[UIImage imageNamed:@"tabbarbg.png"] forState:UIControlStateHighlighted];
    [self.topRightBt setBackgroundImage:[UIImage imageNamed:@"tabbarbg.png"] forState:UIControlStateHighlighted];
    
    
    
    self.gridView.isShowPrivateModifyPwdView = NO;
    self.gridView.gridViewDelegate = self;
    self.gridView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.gridView];
    [self dowloadFriendsData];
	// Do any additional setup after loading the view.
}

-(void)dowloadFriendsData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FriendsViewController __weak *weakSelf = self;
    [FriendObjDao downloadFriendObjsWithCityName:@"" withPageIndex:0 withSuccess:^(NSArray *friendsArr) {
        if (weakSelf) {
            [weakSelf convertFriendobjToDrGridViewData:friendsArr];
            [weakSelf.gridView reloadData];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }
    } withfailure:^(NSError *error) {
        if (weakSelf) {
            [weakSelf alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }
    }];
}

- (void)convertFriendobjToDrGridViewData:(NSArray*)friendArr{
    for (FriendObj *obj in friendArr) {
        DRGridViewData *data = [[DRGridViewData alloc] init];
        data.imageURLStr = obj.webURL;
        data.imageDataID = obj.friendID;
        [self.friendsArr addObject:data];
    }
}
-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBottomLeftBt:nil];
    [self setBottomRightBt:nil];
    [self setTopRightBt:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}
- (IBAction)topRightClicked:(UIButton *)sender {
    
}

- (IBAction)bottomLeftClicked:(UIButton *)sender {
}

- (IBAction)bottomRightClicked:(UIButton *)sender {
    
}

#pragma mark DRGridViewDelegate
-(void)prepareAddNewCellData{
    
}
-(int)numberOfColumns{
    return 2;
}
-(float)heightOfGridViewCell{
    return 120.0;
}
-(int)cacheRowsOfGridView{
    return 10;
}
-(int)numberOfEachPageRows{
    return 20;
}
-(int)numberOfPages{
    return [self.friendsArr count]/20 +[self.friendsArr count]%20 ==0?0:1;
}
-(int)totalCellCount{
    return [self.friendsArr count];
}

-(DRGridViewCell*)gridView:(DRGridView*)gridView cellAtIndex:(int)index{
    DRGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[DRGridViewCell alloc] initWithReuseIdentifier:@"CELL"];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(DRGridViewData*)gridView:(DRGridView*)gridView dataAtIndex:(int)index{
    return [self.friendsArr objectAtIndex:index];
}
-(void)prepareReloadData:(DRGridView*)gridView{

}
-(void)gridView:(DRGridView*)gridView prepareLoadNexPageIndex:(int)pageIndex{
    
}
-(void)gridView:(DRGridView*)gridView didSelectedCellIndex:(int)index{

}
-(void)gridView:(DRGridView*)gridView didDeleteCellIndex:(int)index{

}

-(void)gridView:(DRGridView *)gridView shouldDeleteCellIndex:(int)index{

}

#pragma mark --


#pragma mark property
-(NSMutableArray *)friendsArr{
    if (!_friendsArr) {
        _friendsArr = [NSMutableArray array];
    }
    return _friendsArr;
}

-(DRGridView *)gridView{
    if (!_gridView) {
        _gridView = [[DRGridView alloc] initWithFrame:(CGRect){0,0,self.contentView.frame.size}];
//        _gridView.isForbidingDelete = YES;
//        _gridView.isForbidingAddNewCellFromLocal = YES;
    }
    return _gridView;
}

#pragma mark --
@end

#endif

