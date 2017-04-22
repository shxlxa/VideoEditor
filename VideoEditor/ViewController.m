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
#import "ThumbnailTool.h"

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
    self.videoDuration = [ThumbnailTool getVideoDurationWithUrl:self.myUrl];
}

- (void)addPlayer{
    CGRect rect = CGRectMake(0, 0, kScreenWidth, 9*kScreenWidth/16.0);
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
                UIImage *image = [ThumbnailTool assetGetThumImageWithUrl:self.myUrl time:self.cutTime];
                if (image) {
                    [self.imageArr addObject:image];
                    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png",self.cutCount]];
                    BOOL result = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                    if (result) {
                        NSLog(@"filePath:%@",filePath);
                    }
                    
                }
                self.cutCount ++;
                self.cutTime += self.videoDuration / kImageCount;
                NSLog(@"i %d",i);
                if (i >= kImageCount-1) {
                    self.cutTime = 0;
                    self.cutCount = 0;
                }
            }
        });
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
