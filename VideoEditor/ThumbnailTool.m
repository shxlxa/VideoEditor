//
//  ThumbnailTool.m
//  VideoEditor
//
//  Created by aoni on 2017/4/22.
//  Copyright © 2017年 aoni. All rights reserved.
//

#import "ThumbnailTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation ThumbnailTool

/**
 获取视频总时长
 
 @param url url
 @return 视频总时间：秒
 */
+ (CGFloat)getVideoDurationWithUrl:(NSURL *)url{
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    //获取视频总时间
    CGFloat totaltime = urlSet.duration.value / urlSet.duration.timescale;
    return totaltime;
}

// CMTimeMake CMTimeMakeWithSeconds
//这两个的区别是 CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧.当前播放时间a/b CMTimeMakeWithSeconds(a,b) a当前时间,b每秒钟多少帧.
+ (UIImage *)assetGetThumImageWithUrl:(NSURL *)url time:(CGFloat)second
{
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    //获取视频总时间
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    NSError *error = nil;
    CMTime time = CMTimeMakeWithSeconds(second,10);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
        return nil;
    } else {
        CMTimeShow(actucalTime);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
        UIImageWriteToSavedPhotosAlbum(image,nil, nil,nil);
        CGImageRelease(cgImage);
        NSLog(@"视频截取成功");
        return image;
    }
}




@end
