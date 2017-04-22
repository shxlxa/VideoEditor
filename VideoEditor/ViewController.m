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
#import "Masonry.h"

#define kImageCount 10
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *thImageView;

@property (nonatomic, strong) NSURL  *myUrl;
@property (nonatomic, strong) NSTimer  *timer;
@property (nonatomic, strong) NSMutableArray  *imageArr;

@property (nonatomic, assign) CGFloat cutTime; //截图时间
@property (nonatomic, assign) NSInteger cutCount; //截图次数
@property (nonatomic, assign) NSInteger videoDuration;

@property (nonatomic, strong) WMPlayer  *wmPlayer;
@property (nonatomic, strong) UIImageView  *leftDragImg;
@property (nonatomic, strong) UIImageView  *rightDragImg;
@property (nonatomic, strong) UIView  *containView;
@property (nonatomic, strong) UIPanGestureRecognizer  *leftPanGesture;
@property (nonatomic, strong) UIPanGestureRecognizer  *rightPanGesture;
@property (nonatomic, assign) BOOL canMove;

@property (nonatomic, assign) CGFloat seekTime;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = UIColorHex(0x4c4c4c);
//    [self getAllThumbnailImages];
    [self addPlayer];
    
    self.cutTime = 0.0;
    self.cutCount = 0;
    self.videoDuration = [ThumbnailTool getVideoDurationWithUrl:self.myUrl];
    
    [self addImageViews];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
    
}
- (IBAction)sliderValueChanged:(UISlider *)slider {
    [_wmPlayer pause];
    [_wmPlayer seekToTimeToPlay:self.videoDuration * slider.value];
}

- (void)addPlayer{
    _wmPlayer = [[WMPlayer alloc]initWithFrame:CGRectZero];
    NSString *urlstring = [self.myUrl absoluteString];
    [_wmPlayer setURLString:urlstring];
    [self.view addSubview:_wmPlayer];
    [_wmPlayer play];
    [_wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(9*kScreenWidth/16.0);
    }];
}

- (void)addImageViews{
    UIView *containView = [[UIView alloc] init];
    [self.view addSubview:containView];
    containView.backgroundColor = [UIColor lightGrayColor];
    self.containView = containView;
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_wmPlayer.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(340);
        make.height.mas_equalTo(42);
    }];
    
    for (int i=0; i<kImageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        if (self.imageArr.count) {
            imageView.image = self.imageArr[i];
        }
        [self.containView addSubview:imageView];
        imageView.frame = CGRectMake(15+i*31, 5, 31, 32);
    }
    
    _leftDragImg = [[UIImageView alloc] init];
    _leftDragImg.image = [UIImage imageNamed:@"video_drag_left"];
    _leftDragImg.userInteractionEnabled = YES;
    [containView addSubview:_leftDragImg];
    [_leftDragImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(containView);
        make.width.mas_equalTo(15);
    }];
    
    _rightDragImg = [[UIImageView alloc] init];
    _rightDragImg.image = [UIImage imageNamed:@"video_drag_right"];
    _rightDragImg.userInteractionEnabled = YES;
    [containView addSubview:_rightDragImg];
    [_rightDragImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(containView);
        make.width.mas_equalTo(15);
    }];
    
    _leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanGestureEvent:)];
    [_leftDragImg addGestureRecognizer:_leftPanGesture];
    
    _rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanGestureEvent:)];
    [_rightDragImg addGestureRecognizer:_rightPanGesture];
}

- (void)leftPanGestureEvent:(UIPanGestureRecognizer *)panGesture{
    CGPoint point = [panGesture translationInView:self.view];
    
//    if (_leftDragImg.left>=0 && _leftDragImg.left<=310) {
//        [_leftDragImg setCenter:CGPointMake(_leftDragImg.center.x + point.x, _leftDragImg.center.y)];
//        NSLog(@"x:%.2f",_leftDragImg.left);
//        [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
//    }
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (_leftDragImg.left>=0 && _leftDragImg.left<=310) {
            _canMove = YES;
        } else {
            _canMove = NO;
        }
        
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        if (_canMove && _leftDragImg.left>=0 && _leftDragImg.left<=310) {
            [_leftDragImg setCenter:CGPointMake(_leftDragImg.center.x + point.x, _leftDragImg.center.y)];
            NSLog(@"x:%.2f",_leftDragImg.left);
            [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
        }
    }
   
}

//0xed5848
- (IBAction)item:(id)sender {
    NSLog(@"%.2f",_wmPlayer.currentTime);
    
    self.seekTime += 5;
    [_wmPlayer seekToTimeToPlay:self.seekTime];
}

- (void)getAllThumbnailImages{
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
