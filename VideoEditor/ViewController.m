//
//  ViewController.m
//  VideoEditor
//
//  Created by aoni on 2017/4/21.
//  Copyright © 2017年 aoni. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "YYKit.h"
#import "AppDelegate.h"
#import "WMPlayer.h"

#define kImageCount 8
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *thImageView;

@property (nonatomic, strong) NSURL  *myUrl;
@property (nonatomic, strong) NSTimer  *timer;
@property (nonatomic, strong) NSMutableArray  *imageArr;

@property (nonatomic, assign) CGFloat cutTime; //截图时间
@property (nonatomic, assign) NSInteger cutCount; //截图次数
@property (nonatomic, assign) NSInteger videoDuration;

@property (nonatomic, strong) WMPlayer  *wmPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationController.navigationBar.translucent = NO;
    [self addPlayer];
    
    self.cutTime = 0.0;
    self.cutCount = 0;
    self.videoDuration = [self getVideoDurationWithUrl:self.myUrl];
}

- (void)addPlayer{
    CGRect rect = CGRectMake(0, 0, kScreenWidth, 300);
    _wmPlayer = [[WMPlayer alloc]initWithFrame:rect];
    NSString *urlstring = [self.myUrl absoluteString];
    [_wmPlayer setURLString:urlstring];
    [self.view addSubview:_wmPlayer];
    [_wmPlayer play];
}

- (IBAction)item:(id)sender {
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        // 创建一个分组，用来把一堆任务放到同一个分组里
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, globalQueue, ^{

            for (int i=0; i<kImageCount; i++) {
                [self assetGetThumImageWithUrl:self.myUrl time:self.cutTime];
                self.cutCount ++;
                self.cutTime += self.videoDuration / kImageCount;
                NSLog(@"i %d",i);
                if (i >= kImageCount-1) {
                    self.cutTime = 0;
                    self.cutCount = 0;
                }
            }
        });
    
    //定时0.2秒截图一次，一定可以接到指定的10张图
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerEvent:) userInfo:nil repeats:YES];
}

- (void)timerEvent:(NSTimer *)timer{
    if (self.cutCount < kImageCount) {
        [self assetGetThumImageWithUrl:self.myUrl time:self.cutTime];
        self.cutCount ++;
        self.cutTime += self.videoDuration / kImageCount;
        
    } else {
        self.cutTime = 0;
        self.cutCount = 0;
        [self.timer invalidate];
        NSLog(@"imagecount:%ld",self.imageArr.count);
    }
}

/**
 获取视频总时长

 @param url url
 @return 视频总时间：秒
 */
- (CGFloat)getVideoDurationWithUrl:(NSURL *)url{
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    //获取视频总时间
    CGFloat totaltime = urlSet.duration.value / urlSet.duration.timescale;
    return totaltime;
}


// CMTimeMake CMTimeMakeWithSeconds
//这两个的区别是 CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧.当前播放时间a/b CMTimeMakeWithSeconds(a,b) a当前时间,b每秒钟多少帧.
- (void)assetGetThumImageWithUrl:(NSURL *)url time:(CGFloat)second
{
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:self.myUrl];
    //获取视频总时间
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    NSError *error = nil;
    CMTime time = CMTimeMakeWithSeconds(second,10);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
        return;
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
    UIImageWriteToSavedPhotosAlbum(image,nil, nil,nil);
    CGImageRelease(cgImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thImageView.image = image;
    });
   
    
    if (image) {
        [self.imageArr addObject:image];
        
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png",self.cutCount]];
        BOOL result = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        if (result) {
            NSLog(@"filePath:%@",filePath);
        }
    }
    NSLog(@"视频截取成功");
}

- (NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

- (NSURL *)myUrl{
    if (!_myUrl) {
        NSString *str = [[NSBundle mainBundle] pathForResource:@"Everytime" ofType:@"mp4"];
        _myUrl = [NSURL fileURLWithPath:str];
    }
    return _myUrl;
}

- (void)dealloc
{
    [self.timer invalidate];
}



@end
