//
//  videoRecordViewController.m
//  VideoDemo
//
//  Created by 钟文成(外包) on 16/6/15.
//  Copyright © 2016年 钟文成(外包). All rights reserved.
//

#import "videoRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Focus.h"
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
@interface videoRecordViewController ()<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,strong)UIView*container;//显示视频的view
@property (nonatomic,strong)UIButton*actionBtn;//录制和停止录制按钮
@property (nonatomic, strong)AVCaptureSession*captureSession;//视频对话
@property (nonatomic ,strong)AVCaptureDeviceInput*captureDeviceInput;//设备输入端口
@property (nonatomic ,strong)AVCaptureMovieFileOutput*captureMovieFileOutput;//数据输出端口
@property (nonatomic ,strong)AVCaptureVideoPreviewLayer*captureVideoPreviewLayer;//拍摄预览
@property (nonatomic ,strong)Focus*focusCursor;
//@property (nonatomic ,strong)UIImageView*focusCursor;
@property (assign,nonatomic) BOOL enableRotation;//是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
@property (assign,nonatomic) CGRect *lastBounds;//旋转的前大小
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识
@end

@implementation videoRecordViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addVideoFrame];
    [self createVideoPreviewLayer];
    
    _enableRotation=YES;
   [self addGenstureRecognizer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self createUI];
   
}
//创建视频框架
-(void)addVideoFrame{
    //创建视频对话
     _captureSession=[[AVCaptureSession alloc]init];
    //设置视频录制的质量
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
   //设置摄像
    AVCaptureDevice*videoDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    //添加音频设备
    AVCaptureDevice*audioDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:videoDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
  [self addNotificationToCaptureDevice:videoDevice];
}
//创建视频预览层，用于实时展示摄像头状态
-(void)createVideoPreviewLayer{
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    CALayer *layer=self.container.layer;
    layer.masksToBounds=YES;
    
    _captureVideoPreviewLayer.frame=layer.bounds;
    //_captureVideoPreviewLayer.frame=CGRectMake(30, 300, 200, 100);
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    //[self.view.layer addSublayer:_captureVideoPreviewLayer];
   
    
}
-(void)addGenstureRecognizer{
    UIGestureRecognizer*tapgensture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusTransfer:)];
    [_container addGestureRecognizer:tapgensture];
}
-(void)focusTransfer:(UITapGestureRecognizer*)genture{
    CGPoint point=[genture locationInView:_container];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];

}
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
    }];
}/**
  *  改变设备属性的统一操作方法
  *
  *  @param propertyChange 属性改变操作
  */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}
//设置聚焦和曝光点以及模式
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}
//得到摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}
-(void)createUI{
    _container=[[UIView alloc]initWithFrame:CGRectMake(10, 100, 300, 200)];
    _container.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_container];

    _actionBtn=[[UIButton alloc]initWithFrame:CGRectMake(50, 400, 80, 30)];
    [_actionBtn setTitle:@"开始录制" forState:UIControlStateNormal];
    
    [_actionBtn setBackgroundColor:[UIColor redColor]];
    [_actionBtn addTarget:self action:@selector(bttnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_actionBtn];
    UIButton*backBtn=[[UIButton alloc]initWithFrame:CGRectMake(150, 400, 80, 30)];
    [backBtn setBackgroundColor:[UIColor redColor]];
    [backBtn setTitle:@" 返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
     self.focusCursor=[[Focus alloc]initWithFrame:CGRectMake(50, 150, 100, 100)];
    _focusCursor.backgroundColor=[UIColor clearColor];
    _focusCursor.alpha=0;
    [_container addSubview:_focusCursor];

    
}
-(void)backBtnClick:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)bttnClick:(UIButton*)sender{
  if ([sender.titleLabel.text isEqualToString:@"开始录制"]) {
        [_actionBtn setTitle:@"停止" forState:UIControlStateNormal];
      [self startRecordingVideo];
  }else{
  
    [_actionBtn setTitle:@"开始录制" forState:UIControlStateNormal];
    [self.captureMovieFileOutput stopRecording];
  }
  
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}

-(BOOL)shouldAutorotate{
    return self.enableRotation;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//屏幕旋转时调整视频预览图层的方向
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    AVCaptureConnection *captureConnection=[self.captureVideoPreviewLayer connection];
    captureConnection.videoOrientation=(AVCaptureVideoOrientation)toInterfaceOrientation;
}
//旋转后重新设置大小
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    _captureVideoPreviewLayer.frame=self.container.bounds;
}
-(void)startRecordingVideo{
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        self.enableRotation=NO;
        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
        NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        NSLog(@"save path is :%@",outputFielPath);
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
//    else{
//        [self.captureMovieFileOutput stopRecording];//停止录制
//    }
 }
#pragma -mark AVCaptureFileOutputRecordingDelegate
//开始录制视频回调
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
}
 //录制视频完成之后的回调
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
    [self videoCompressionWithUrl:outputFileURL];
 //视频录入完成之后在后台将视频存储到相簿
    self.enableRotation=YES;
    UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier=self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier=UIBackgroundTaskInvalid;
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
        }
        NSLog(@"成功保存视频到相簿.");
    }];
}
//压缩视频
-(void)videoCompressionWithUrl:(NSURL *)url{
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *destFilePath = [docuPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",[[[NSUUID UUID]UUIDString]substringToIndex:8]]];
    NSURL *destUrl = [NSURL fileURLWithPath:destFilePath];
    
    //将视频文件copy到沙盒目录中
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager copyItemAtURL:url toURL:destUrl error:&error];
    //加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:destUrl];
    //创建视频资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //创建导出视频的URL
    NSString *resultPath = [docuPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",[[[NSUUID UUID]UUIDString]substringToIndex:8]]];
    session.outputURL = [NSURL fileURLWithPath:resultPath];
    //必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    //导出视频
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"压缩后的视频地址为 %@",resultPath);
        NSData*data=[NSData dataWithContentsOfFile:resultPath];
        NSLog(@"---%@----",data);
        //删除沙盒中的高质量视频文件
        [manager removeItemAtPath:destFilePath error:nil];
        
        
    }];
    
    
}
//- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
//                               outputURL:(NSURL*)outputURL
//                         completeHandler:(void (^)(AVAssetExportSession*))handler
//{
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
//    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset     presetName:AVAssetExportPresetMediumQuality];
//    exportSession.outputURL = outputURL;
//    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
//        switch (exportSession.status)
//        {
//            case AVAssetExportSessionStatusUnknown:
//                NSLog(@"---weizhicuowu---");
//                break;
//            case AVAssetExportSessionStatusWaiting:
//                NSLog(@"-----dengdai-----");
//                break;
//            case AVAssetExportSessionStatusExporting:
//                NSLog(@"----daochu-----");
//                break;
//            case AVAssetExportSessionStatusCompleted: {
//                NSLog(@"---wancheng---");
//                handler(exportSession);
//                break;
//            }
//            case AVAssetExportSessionStatusFailed:
//                NSLog(@"----shibai----");
//                break;
//        }
//    }];
//}
//在视频中抓取一张图片
- (UIImage *)frameImageFromVideoURL:(NSURL *)videoURL {
    // result
    UIImage *image = nil;
    
    // AVAssetImageGenerator
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // calculate the midpoint time of video
    Float64 duration = CMTimeGetSeconds([asset duration]);
    // 取某个帧的时间，参数一表示哪个时间（秒），参数二表示每秒多少帧
    // 通常来说，600是一个常用的公共参数，苹果有说明:
    // 24 frames per second (fps) for film, 30 fps for NTSC (used for TV in North America and
    // Japan), and 25 fps for PAL (used for TV in Europe).
    // Using a timescale of 600, you can exactly represent any number of frames in these systems
    CMTime midpoint = CMTimeMakeWithSeconds(duration / 2.0, 600);
    
    // get the image from
    NSError *error = nil;
    CMTime actualTime;
    // Returns a CFRetained CGImageRef for an asset at or near the specified time.
    // So we should mannully release it
    CGImageRef centerFrameImage = [imageGenerator copyCGImageAtTime:midpoint
                                                         actualTime:&actualTime
                                                              error:&error];
    
    if (centerFrameImage != NULL) {
        image = [[UIImage alloc] initWithCGImage:centerFrameImage];
        // Release the CFRetained image
        CGImageRelease(centerFrameImage);
    }
    
    return image;
}
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}

#pragma mark 切换前后摄像头
- (void)toggleButtonClick:(UIButton *)sender {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
        
    }else{
        toChangePosition=AVCaptureDevicePositionFront;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
    
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
