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

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView*showPlayerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 280,200)];
    showPlayerView.backgroundColor=[UIColor redColor];
    [self.view addSubview:showPlayerView];
    NSURL *url2 = [NSURL URLWithString:@"http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"];
    //NSURL*url=[NSURL URLWithString:@"http://krtv.qiniudn.com/150522nextapp"];
    [[TBPlayer sharedInstance] playWithUrl:url2 showView:showPlayerView];
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
