//
//  Temp.m
//  VideoEditor
//
//  Created by aoni on 2017/4/22.
//  Copyright © 2017年 aoni. All rights reserved.
//

#import "Temp.h"

@implementation Temp


/*
 if (panGesture.state == UIGestureRecognizerStateEnded) {
 [UIView animateWithDuration:0.25 animations:^{
 //            _leftDragImg.centerY = _containView.centerY;
 } completion:nil];
 }
 else if (panGesture.state == UIGestureRecognizerStateBegan) {
 CGPoint location = [panGesture locationInView:self.view];
 // CGRectContainsPoint 判断一个点是不是在一个矩形里面
 CGRect absoluteFrame = CGRectMake(_leftDragImg.left+_containView.left, _leftDragImg.top+_containView.top, _leftDragImg.width, _leftDragImg.height);
 if (CGRectContainsPoint(absoluteFrame, location)) {
 _canMove = YES;
 }
 else {
 _canMove = NO;
 }
 }
 else {
 // 相对于指定的View的偏移
 // 与原始位置的差值
 CGPoint point = [panGesture translationInView:self.view];
 //        CGPoint location = [panGesture locationInView:self.view];
 if (_canMove) {
 //            _
 [_leftDragImg mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(_containView).offset(point.x);
 }];
 }
 }

 */

@end
