//
//  ThumbnailTool.h
//  VideoEditor
//
//  Created by aoni on 2017/4/22.
//  Copyright © 2017年 aoni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ThumbnailTool : NSObject

/**
 获取视频总时长
 
 @param url url
 @return 视频总时间：秒
 */
+ (CGFloat)getVideoDurationWithUrl:(NSURL *)url;


/**
 获取视频的某一时刻的截图

 @param url 视频url
 @param second 截图时间
 @return 返回的图片
 */
+ (UIImage *)assetGetThumImageWithUrl:(NSURL *)url time:(CGFloat)second;

@end
