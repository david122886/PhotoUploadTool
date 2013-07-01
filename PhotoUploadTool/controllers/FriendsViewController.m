//
//  FriendsViewController.m
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "FriendsViewController.h"
#define GRIDVIEW_SPACE 5.0
#define GRIDVIEW_CELL_HEIGHT 170.0
#define GRIDVIEW_CELL_WIDTH 150.0
#define GRIDVIEW_COLOUMN_COUNT  2
@interface FriendsViewController ()
@property (nonatomic,strong) NSMutableArray *friendsArr;
@property (nonatomic,strong) GridView *gridView;
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
    self.gridView.gridDelegate = self;
    [self.contentView addSubview:self.gridView];
    [self dowloadFriendsData];
	// Do any additional setup after loading the view.
}

-(void)dowloadFriendsData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FriendsViewController __weak *weakSelf = self;
    [FriendObjDao downloadFriendObjsWithCityName:@"" withPageIndex:0 withSuccess:^(NSArray *friendsArr) {
        if (weakSelf) {
            [weakSelf.friendsArr addObjectsFromArray:friendsArr];
            [weakSelf.gridView reloadGrid];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }
    } withfailure:^(NSError *error) {
        if (weakSelf) {
            [weakSelf alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
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
    [super viewDidUnload];
}
- (IBAction)topRightClicked:(UIButton *)sender {
}

- (IBAction)bottomLeftClicked:(UIButton *)sender {
}

- (IBAction)bottomRightClicked:(UIButton *)sender {
    
}

#pragma mark GridCellDelegate
/** Required methods **/
- (NSInteger)numberOfRowsInGridView:(GridView*)gridView {
    int rowCount = [self.friendsArr count]/GRIDVIEW_COLOUMN_COUNT + ([self.friendsArr count]%GRIDVIEW_COLOUMN_COUNT > 0? 1 : 0);
	return rowCount;
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
    if (index.row*2+index.column >= [self.friendsArr count]) {
        
        return cell;
    }
    FriendObj *friend = [self.friendsArr objectAtIndex:index.row*2+index.column];
    [cell.cellimageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:friend.webURL]] placeholderImage:[UIImage imageNamed:@"titleLogo.png"] success:nil  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
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
        _gridView = [[GridView alloc] initWithFrame:(CGRect){0,0,self.contentView.frame.size}];
    }
    return _gridView;
}
#pragma mark --
@end
