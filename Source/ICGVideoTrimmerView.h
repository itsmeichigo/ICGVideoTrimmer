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

// Video to be trimmed
@property (strong, nonatomic) AVAsset *asset;

// Theme color for the trimmer view
@property (strong, nonatomic) UIColor *themeColor;

// Maximum length for the trimmed video
@property (assign, nonatomic) CGFloat maxLength;

// Minimum length for the trimmed video
@property (assign, nonatomic) CGFloat minLength;

// Show ruler view on the trimmer view or not
@property (assign, nonatomic) BOOL showsRulerView;

// Customize color for tracker
@property (assign, nonatomic) UIColor *trackerColor;

// Custom image for the left thumb
@property (strong, nonatomic) UIImage *leftThumbImage;

// Custom image for the right thumb
@property (strong, nonatomic) UIImage *rightThumbImage;

// Custom width for the top and bottom borders
@property (assign, nonatomic) CGFloat borderWidth;

// Custom width for thumb
@property (assign, nonatomic) CGFloat thumbWidth;

@property (weak, nonatomic) IBOutlet id<ICGVideoTrimmerDelegate> delegate;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;

- (void)resetSubviews;

- (void)seekToTime:(CGFloat)startTime;

- (void)hideTracker:(BOOL)flag;

@end

@protocol ICGVideoTrimmerDelegate <NSObject>

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime;

@end
