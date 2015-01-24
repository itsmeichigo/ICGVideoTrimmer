//
//  ICGVideoTrimmerView.h
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ICGVideoTrimmerDelegate;

@interface ICGVideoTrimmerView : UIView

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) UIColor *themeColor;

@property (assign, nonatomic) CGFloat maxLength;
@property (assign, nonatomic) CGFloat minLength;
@property (assign, nonatomic) BOOL showsRulerView;

@property (strong, nonatomic) id<ICGVideoTrimmerDelegate> delegate;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;

- (void)resetSubviews;

@end

@protocol ICGVideoTrimmerDelegate <NSObject>

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime;

@end
