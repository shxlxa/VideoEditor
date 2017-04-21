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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *thImageView;

@property (nonatomic, strong) NSURL  *myUrl;

@property (nonatomic, assign) NSInteger cutCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *str = [[NSBundle mainBundle] pathForResource:@"Everytime" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:str];
    self.myUrl = url;
    
//    self.myUrl = [NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    
    self.cutCount = 0;
}

- (IBAction)item:(id)sender {
    
   
    self.cutCount += 5;
    [self assetGetThumImage:self.cutCount];
    
//    [self thumbnailImageForVideo:self.myUrl atTime:63.0];
}


// CMTimeMake CMTimeMakeWithSeconds
//这两个的区别是 CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧.当前播放时间a/b CMTimeMakeWithSeconds(a,b) a当前时间,b每秒钟多少帧.
- (void)assetGetThumImage:(CGFloat)second
{
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:self.myUrl];
    //获取视频总时间
    CGFloat totaltime = urlSet.duration.value / urlSet.duration.timescale;
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
    UIImageWriteToSavedPhotosAlbum(image,nil, nil,nil);
    CGImageRelease(cgImage);
    self.thImageView.image = image;
    NSLog(@"视频截取成功");
}




@end
