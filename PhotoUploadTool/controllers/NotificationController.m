//
//  NotificationController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "NotificationController.h"
#import "NotificationCell.h"
#import "AppDelegate.h"
#import "NotificationDao.h"
#import "MBProgressHUD.h"
#define NOTIFICATION_FONT_SIZE  15
@interface NotificationController ()
@property(nonatomic,strong) EGORefreshTableHeaderView *refreshView;
@property(nonatomic,strong)NSMutableArray *notificationArr;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign) BOOL isloadingData;
@end

@implementation NotificationController

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
    self.tabbarTitleLabel.text = @"通知列表";
    [self.tabbarRightBt setTitle:@"编辑" forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"privatePwd_bg.png"]];
    
    [self.tabbarRightBt setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal];
    [self.tabbarRightBt setBackgroundImage:[UIImage imageNamed:@"out_btn.png"] forState:UIControlStateHighlighted];
//    [self.tabbarRightBt setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	// Do any additional setup after loading the view.
//    for (int i = 0; i < 20; i++) {
//        [self.notificationArr addObject:[NotificationObject initNotificationWithDateStr:@"2012/01/01" withDetailStr:@"umhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9oniumhoiumh9s9s8g9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s98g9msoiihsoshhis vnyguiwh m0ws9ui ,s9u"]];
//    }
    [self.contentView addSubview:self.tableView];
    [self downloadnotification];
}

-(void)downloadnotification{
    if (self.notiArr && [self.notiArr count] > 0) {
        [self.notificationArr removeAllObjects];
        [self.notificationArr addObjectsFromArray:self.notiArr];
        [self loadedData];
        return;
    }
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NotificationController __weak *weakNotiCtr = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NotificationDao notificationDaoDownloadWithUserObjID:appDelegate.user.userId WithSuccess:^(NSArray *notificationArr) {
        NotificationController *notiCtr = weakNotiCtr;
        [MBProgressHUD hideHUDForView:notiCtr.view animated:YES];
        [notiCtr.notificationArr removeAllObjects];
        [notiCtr.notificationArr addObjectsFromArray:notificationArr];
        [notiCtr loadedData];
    } withFailure:^(NSError *error) {
        NotificationController *notiCtr = weakNotiCtr;
        [MBProgressHUD hideHUDForView:notiCtr.view animated:YES];
        [notiCtr alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        [notiCtr loadedData];
    }];
}

-(void)deleteNotificationAtIndexPath:(NSIndexPath*)indexPath{
    NotificationController __weak *weakNotiCtr = self;
    NotificationObject *deletedObj = [self.notificationArr objectAtIndex:indexPath.row];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    [NotificationDao deleteNotificationWithNotificationID:deletedObj.notificationID withNotID:obj.notificationID withSuccess:^(NSString *success){
        NotificationController *notiCtr = weakNotiCtr;
        [MBProgressHUD hideHUDForView:notiCtr.view animated:YES];
        [notiCtr deleteCellAtIndexPath:indexPath];
    } withFailure:^(NSError *error) {
        NotificationController *notiCtr = weakNotiCtr;
        [MBProgressHUD hideHUDForView:notiCtr.view animated:YES];
        [notiCtr alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
    
}

-(void)deleteCellAtIndexPath:(NSIndexPath*)indexPath{
    [self.notificationArr removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    if (indexPath) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(NSString*)convertDateFormat:(NSString*)dateStr{
    if (!dateStr) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [formatter dateFromString:dateStr];
    
    [formatter setAMSymbol:@"上午"];
    [formatter setPMSymbol:@"下午"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:date];
}

-(void)loadedData{
    self.isloadingData = NO;
    [self.tableView reloadData];
    [self.refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

//继承该方法时,左右滑动会出现删除按钮(自定义按钮),点击按钮时的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self deleteNotificationAtIndexPath:indexPath];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


//当 tableview 为 editing 时,左侧按钮的 style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    cell.dateLabel.text = [self convertDateFormat:obj.date];
    cell.summaryLabel.text = obj.deail;
    cell.backImageView.image = [[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    cell.detalLabel.text = obj.deail;
    if ([obj.isExpand boolValue]) {
        [cell.summaryLabel setHidden:YES];
        [cell.detalLabel setHidden:NO];
        cell.detalLabel.numberOfLines = 0;
        [cell.detalLabel sizeToFit];
    }else{
        [cell.summaryLabel setHidden:NO];
        [cell.detalLabel setHidden:YES];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    if ([obj.isExpand boolValue]) {
        CGSize detailSize = [obj.deail sizeWithFont:[UIFont systemFontOfSize:NOTIFICATION_FONT_SIZE] constrainedToSize:CGSizeMake(279, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        if (detailSize.width > tableView.frame.size.width) {
            return detailSize.height +41;
        }
    }
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    obj.isExpand = [NSNumber numberWithBool:![obj.isExpand boolValue]];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.notificationArr count];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)notificationArr{
    if (!_notificationArr) {
        _notificationArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _notificationArr;
}

#pragma mark property

-(EGORefreshTableHeaderView *)refreshView{
    if (!_refreshView) {
        _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -150, self.view.frame.size.width, 150)];
        _refreshView.backgroundColor = [UIColor clearColor];
        _refreshView.delegate = self;
        [self.tableView addSubview:_refreshView];
    }
    return _refreshView;
}

-(UITableView *)tableView{
    if (!_tableView) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
        _tableView = (UITableView*)[[story instantiateViewControllerWithIdentifier:@"NotificationTableViewController"] view];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
#pragma mark --

-(void)refreshNotificationDatas{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NotificationController __weak *weakNotiCtr = self;
    [NotificationDao notificationDaoDownloadWithUserObjID:appDelegate.user.userId WithSuccess:^(NSArray *notificationArr) {
        NotificationController *notiCtr = weakNotiCtr;
        [notiCtr.notificationArr removeAllObjects];
        [notiCtr.notificationArr addObjectsFromArray:notificationArr];
        [notiCtr loadedData];
    } withFailure:^(NSError *error) {
        NotificationController *notiCtr = weakNotiCtr;
        [notiCtr alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        [notiCtr loadedData];
    }];
}

#pragma mark EGORefreshTableDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	self.isloadingData = YES;
//    [self performSelector:@selector(loadedData) withObject:nil afterDelay:3.0];
    [self refreshNotificationDatas];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return self.isloadingData; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark ScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.tableView.editing) {
        return;
    }
    [self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.editing) {
        return;
    }
    [self.refreshView egoRefreshScrollViewDidScroll:scrollView];
    
}
#pragma mark --
- (IBAction)backBtClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setTabbarTitleLabel:nil];
    [self setContentView:nil];
    [self setTabbarRightBt:nil];
    [super viewDidUnload];
}
- (IBAction)tabbarEditBtClicked:(UIButton *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    //    [self.tableView reloadData];
    if (self.tableView.editing) {
        [self.tabbarRightBt setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        [self.tabbarRightBt setTitle:@"编辑" forState:UIControlStateNormal];
    }
}
@end
