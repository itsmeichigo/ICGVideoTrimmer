//
//  ICGVideoTrimmerView.h
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ICGVideoTrimmerView : UIView

@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat maxLength;
@property (assign, nonatomic) CGFloat minLength;
@property (strong, nonatomic) UIColor *themeColor;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;

- (void)resetSubviews;

@end
