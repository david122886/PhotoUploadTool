//
//  ReportViewController.m
//  PhotoUploadTool
//
//  Created by david on 13-8-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "ReportViewController.h"
#import "FriendsViewController.h"
@interface ReportViewController ()

@end

@implementation ReportViewController

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
    self.textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"registerbg.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)agreeReport:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:FIRST_USE_APP];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
    FriendsViewController *navi = [story instantiateViewControllerWithIdentifier:@"FriendsViewController"];
    [self.navigationController pushViewController:navi animated:NO];
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
- (IBAction)backBtClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
