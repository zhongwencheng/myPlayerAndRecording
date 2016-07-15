//
//  PlayerViewController.m
//  VideoDemo
//
//  Created by 钟文成(外包) on 16/7/14.
//  Copyright © 2016年 钟文成(外包). All rights reserved.
//

#import "PlayerViewController.h"
#import "TBPlayer.h"
@interface PlayerViewController ()
@property(nonatomic ,strong)UIView*showPlayerView;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _showPlayerView=[[UIView alloc]initWithFrame:CGRectMake(20, 0, 280,200)];
    _showPlayerView.backgroundColor=[UIColor redColor];
    [self.view addSubview:_showPlayerView];
    NSURL *url2 = [NSURL URLWithString:@"http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"];
    //NSURL*url=[NSURL URLWithString:@"http://krtv.qiniudn.com/150522nextapp"];
    [[TBPlayer sharedInstance] playWithUrl:url2 showView:_showPlayerView];
    [_showPlayerView addSubview:[TBPlayer sharedInstance].navBar];
    UIButton*backBtn=[[UIButton alloc]initWithFrame:CGRectMake(130, 320, 50, 30)];
    [backBtn setBackgroundColor:[UIColor redColor]];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitle:@"back" forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backBtnClick:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}
-(void)viewWillAppear:(BOOL)animated{
  
  [TBPlayer sharedInstance].navBar.hidden=NO;

  }
-(void)backBtnClick:(UIButton*)sender{

    [self dismissViewControllerAnimated:YES completion:nil];
    [[TBPlayer sharedInstance] pause];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
