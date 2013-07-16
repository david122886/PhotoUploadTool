//
//  FriendPhotoViewController.m
//  PhotoUploadTool
//
//  Created by david on 13-7-11.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "FriendPhotoViewController.h"
#import "SettingPrivatePwdView.h"
#define GRIDVIEW_SPACE 5.0
#define GRIDVIEW_CELL_HEIGHT 140.0
#define GRIDVIEW_CELL_WIDTH 100.0
#define GRIDVIEW_COLOUMN_COUNT  3
@interface FriendPhotoViewController ()
@property (nonatomic,strong) NSMutableArray *friendsArr;
@property (nonatomic,strong) GridView *gridView;
@end

@implementation FriendPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    self.gridView.gridDelegate = self;
    [self.contentView addSubview:self.gridView];
    [self.gridView reloadGrid];
//    [self downloadFriendsPhotosWithImageType:PUBLIC_IMAGEDATA];
	// Do any additional setup after loading the view.
}

- (void)typeAlbumPwd{
    FriendPhotoViewController __weak *weakSelf = self;
    [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_IDENTIFY withAlbumPwd:nil withSuccess:^(NSString *password) {
        if (weakSelf) {
            [weakSelf identifyAlbumPwdFromServerWithAlbumPwd:password];
        }
    } orFailure:^(NSError *error) {
        
    } orCancel:^{
        
    }];
}

- (void)identifyAlbumPwdFromServerWithAlbumPwd:(NSString*)albumPwd{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FriendPhotoViewController __weak *weakSelf = self;
    [FriendObjDao identifyFriendAlbumPwdWithFriendObjID:self.friendID withAlbumPwd:albumPwd withSuccess:^(NSString *success) {
        if (weakSelf) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            weakSelf.isLocked = NO;
            [weakSelf downloadFriendsPhotosWithImageType:PRIVATE_IMAGEDATA];
        }
        
    } withfailure:^(NSError *error) {
        if (weakSelf) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        }
    }];
}

- (void)scanAlbumPhotoAtIndex:(int)index{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    //browser.wantsFullScreenLayout = NO;
    //[browser setInitialPageIndex:2];
    browser.isForbidingDelete = YES;
    browser.view.frame = [[UIScreen mainScreen] bounds];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser setInitialPageIndex:index];
}

- (void)downloadFriendsPhotosWithImageType:(ImageDataType)type{
    if (!self.friendID) {
        return;
    }
    FriendPhotoViewController __weak *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.gridView.isLoading = YES;
    [DRImageTool downLoadDRImageDataWithUserID:self.friendID withType:type withSuccess:^(NSArray *drImageDataArr) {
        if (weakSelf) {
            if (type == PUBLIC_IMAGEDATA) {
                [weakSelf.friendsArr removeAllObjects];
                [weakSelf.friendsArr addObjectsFromArray:drImageDataArr];
                if (weakSelf.isLocked) {
                    DRImageObj *lockedobj = [[DRImageObj alloc] init];
                    lockedobj.isLocked = YES;
                    [weakSelf.friendsArr addObject:lockedobj];
                }
            }else{
                if (!weakSelf.isLocked && [weakSelf.friendsArr count] > 0) {
                    [weakSelf.friendsArr removeLastObject];
                }
                [weakSelf.friendsArr addObjectsFromArray:drImageDataArr];
            }
            [weakSelf.gridView reloadGrid];
            weakSelf.gridView.isLoading = NO;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.gridView.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:weakSelf.gridView];
        }
    } withFailure:^(NSError *error) {
        if (weakSelf) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            weakSelf.gridView.isLoading = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)backBtClicked:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setContentView:nil];
    [super viewDidUnload];
}

#pragma mark GridCellDelegate
/** Required methods **/
- (NSInteger)numberOfRowsInGridView:(GridView*)gridView {
    int rowCount = [self.friendsArr count]/GRIDVIEW_COLOUMN_COUNT + ([self.friendsArr count]%GRIDVIEW_COLOUMN_COUNT > 0? 1 : 0);
	return rowCount;
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
    NSLog(@"row:%d,column:%d,index:%d",index.row,index.column,index.row*GRIDVIEW_COLOUMN_COUNT+index.column);
    DRImageObj *imageObj =  [self.friendsArr objectAtIndex:index.row*GRIDVIEW_COLOUMN_COUNT+index.column];
    if (imageObj.isLocked) {
        [cell.cellimageView setImage:[UIImage imageNamed:@"lock.png"]];
    }else{
        [cell.cellimageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageObj.smallImageURLStr]] placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:nil  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
//    [cell.cellButton setTitle:[NSString stringWithFormat:@"row:%d,column:%d,index:%d",index.row,index.column,index.row*GRIDVIEW_COLOUMN_COUNT+index.column] forState:UIControlStateNormal];
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
    NSLog(@"row:%d,column:%d,index:%d",index.row,index.column,index.row*GRIDVIEW_COLOUMN_COUNT+index.column);
    int cellIndex = index.row*GRIDVIEW_COLOUMN_COUNT+index.column;
    if (self.isLocked && cellIndex == [self.friendsArr count] - 1) {
        [self typeAlbumPwd];
    }else{
        [self scanAlbumPhotoAtIndex:cellIndex];
    }
}

- (void)gridViewReloadData:(GridView*)gridView{
    self.isLocked = YES;
    [self downloadFriendsPhotosWithImageType:PUBLIC_IMAGEDATA];
//    [self downloadFriendsPhotosWithImageType:PRIVATE_IMAGEDATA];
}


#pragma mark --

#pragma mark - MWPhotoBrowserDelegate

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser backAtIndex:(NSUInteger)index{

}
-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletedPhotoAtIndex:(NSUInteger)index{

}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (self.isLocked) {
        return self.friendsArr.count -1;
    }
    return self.friendsArr.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.friendsArr.count){
        DRImageObj *imageObj = [self.friendsArr objectAtIndex:index];
        return [MWPhoto photoWithURL:[NSURL URLWithString:imageObj.bigImageURLStr]];
    }
       
    return nil;
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser shoulddeletedPhotoAtIndex:(NSUInteger)index{

}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}
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
        _gridView = [[GridView alloc] initWithFrame:(CGRect){0,0,self.contentView.frame.size}];
        _gridView.isLoading = NO;
    }
    return _gridView;
}
#pragma mark --
@end
