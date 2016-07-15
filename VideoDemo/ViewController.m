//
//  ViewController.m
//  VideoDemo
//
//  Created by 钟文成(外包) on 16/6/15.
//  Copyright © 2016年 钟文成(外包). All rights reserved.
//

#import "ViewController.h"
#import "videoRecordViewController.h"
#import "Focus.h"
#import "PlayerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton*btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 200, 80, 30)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"录制视频" forState:UIControlStateNormal];
    [btn setTitle:@"recording" forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    UIButton*PlayerBtn=[[UIButton alloc]initWithFrame:CGRectMake(100, 260, 80, 30)];
    [PlayerBtn setBackgroundColor:[UIColor redColor]];
    [PlayerBtn setTitle:@"播放视频" forState:UIControlStateNormal];
    [PlayerBtn setTitle:@"play on" forState:UIControlStateHighlighted];
    [PlayerBtn addTarget:self action:@selector(playerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:PlayerBtn];
    
}
-(void)playerBtnClick:(UIButton*)btn{
    PlayerViewController*PlayerVC=[[PlayerViewController alloc]init];
    [self presentViewController:PlayerVC animated:YES completion:nil];
}
-(void)recordBtnClick:(UIButton*)btn{
    videoRecordViewController*videC=[[videoRecordViewController alloc]init];
    [self presentViewController:videC animated:YES completion:nil];
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
