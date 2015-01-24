//
//  ICGVideoTrimmerView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGVideoTrimmerView.h"
#import "ICGThumbView.h"

@interface ICGVideoTrimmerView() <UIScrollViewDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@property (strong, nonatomic) UIView *leftOverlayView;
@property (strong, nonatomic) UIView *rightOverlayView;
@property (strong, nonatomic) ICGThumbView *leftThumbView;
@property (strong, nonatomic) ICGThumbView *rightThumbView;

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat endTime;

@property (nonatomic) CGFloat widthPerSecond;
@end

@implementation ICGVideoTrimmerView

#pragma mark - Initiation

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        [self resetSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset
{
    self = [super initWithFrame:frame];
    if (self) {
        _asset = asset;
        [self resetSubviews];
    }
    return self;
}


#pragma mark - Private methods

- (void)resetSubviews
{
    if (self.maxLength == 0) {
        self.maxLength = 15;
    }
    
    if (self.minLength == 0) {
        self.minLength = 3;
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.scrollView];
    [self.scrollView setDelegate:self];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
    [self.contentView setClipsToBounds:YES];
    [self.contentView.layer setCornerRadius:5];
    [self.scrollView setContentSize:self.contentView.frame.size];
    [self.scrollView addSubview:self.contentView];
    
    [self addFrames];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    [topBorder setBackgroundColor:self.themeColor];
    [self addSubview:topBorder];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1)];
    [bottomBorder setBackgroundColor:self.themeColor];
    [self addSubview:bottomBorder];
    
    
    self.leftOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
    self.leftThumbView = [[ICGThumbView alloc] initWithFrame:self.leftOverlayView.frame color:self.themeColor right:NO];
    [self.leftOverlayView addSubview:self.leftThumbView];
    [self.leftOverlayView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *leftPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeftOverlayView:)];
    [self.leftOverlayView addGestureRecognizer:leftPanGestureRecognizer];
    [self.leftOverlayView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    [self addSubview:self.leftOverlayView];
    
    CGFloat rightViewFrameX = (CGRectGetWidth(self.contentView.frame) < CGRectGetWidth(self.frame) ? CGRectGetWidth(self.contentView.frame) : CGRectGetWidth(self.frame)) - 10;
    self.rightOverlayView = [[UIView alloc] initWithFrame:CGRectMake(rightViewFrameX, 0, 10, CGRectGetHeight(self.frame))];
    self.rightThumbView = [[ICGThumbView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height) color:self.themeColor right:YES];
    [self.rightOverlayView addSubview:self.rightThumbView];
    [self.rightOverlayView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *rightPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveRightOverlayView:)];
    [self.rightOverlayView addGestureRecognizer:rightPanGestureRecognizer];
    [self.rightOverlayView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    [self addSubview:self.rightOverlayView];
}

- (void)moveLeftOverlayView:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:self];
        
        CGFloat newLeftViewWidth = CGRectGetWidth(self.leftOverlayView.frame)+translation.x;
        CGFloat totalWidth = CGRectGetWidth(self.contentView.frame) < CGRectGetWidth(self.frame) ? CGRectGetWidth(self.contentView.frame) : CGRectGetWidth(self.frame);
        CGFloat maxWidth = totalWidth - CGRectGetWidth(self.rightOverlayView.frame) - (self.minLength * self.widthPerSecond);
        if (newLeftViewWidth < 10) {
            newLeftViewWidth = 10;
        } else if (newLeftViewWidth > maxWidth) {
            newLeftViewWidth = maxWidth;
        }
        [self.leftOverlayView setFrame:CGRectMake(0, 0, newLeftViewWidth, CGRectGetHeight(self.leftOverlayView.frame))];
        [self.leftThumbView setFrame:CGRectMake(newLeftViewWidth-10, 0, 10, self.frame.size.height)];
        
        [self notifyDelegate];
    }
    
}

- (void)moveRightOverlayView:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:self];
        
        CGFloat newRightViewWidth = CGRectGetWidth(self.rightOverlayView.frame)-translation.x;
        CGFloat totalWidth = CGRectGetWidth(self.contentView.frame) < CGRectGetWidth(self.frame) ? CGRectGetWidth(self.contentView.frame) : CGRectGetWidth(self.frame);
        CGFloat maxWidth = totalWidth - CGRectGetWidth(self.leftOverlayView.frame) - (self.minLength * self.widthPerSecond);
        if (newRightViewWidth < 10) {
            newRightViewWidth = 10;
        } else if (newRightViewWidth > maxWidth) {
            newRightViewWidth = maxWidth;
        }
        [self.rightOverlayView setFrame:CGRectMake(CGRectGetWidth(self.frame)-newRightViewWidth, 0, newRightViewWidth, CGRectGetHeight(self.rightOverlayView.frame))];
        
        [self notifyDelegate];
    }
}

- (void)notifyDelegate
{
    self.startTime = CGRectGetWidth(self.leftOverlayView.frame) / self.widthPerSecond + self.scrollView.contentOffset.x / self.widthPerSecond;
    self.endTime = CGRectGetMinX(self.rightOverlayView.frame) / self.widthPerSecond + self.scrollView.contentOffset.x / self.widthPerSecond;
    NSLog(@"start time: %f, end time: %f", self.startTime, self.endTime);
    [self.delegate trimmerView:self didChangeLeftPosition:self.startTime rightPosition:self.endTime];
}

- (void)addFrames
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(self.contentView.frame.size.width*2, self.contentView.frame.size.height*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
    
    CGFloat picWidth = 0;
    
    // First image
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    if (halfWayImage != NULL) {
        UIImage *videoScreen;
        if ([self isRetina]){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect = tmp.frame;
        rect.size.width = videoScreen.size.width;
        tmp.frame = rect;
        [self.contentView addSubview:tmp];
        picWidth = tmp.frame.size.width;
        CGImageRelease(halfWayImage);
    }
    
    CGFloat duration = CMTimeGetSeconds([self.asset duration]);
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger actualFramesNeeded;
    
    CGFloat contentViewFrameWidth = (duration / self.maxLength) * screenWidth;
    [self.contentView setFrame:CGRectMake(0, 0, contentViewFrameWidth, CGRectGetHeight(self.contentView.frame))];
    [self.scrollView setContentSize:self.contentView.frame.size];
    NSInteger minFramesNeeded = screenWidth / picWidth + 1;
    actualFramesNeeded =  (duration / self.maxLength) * minFramesNeeded;
    
    CGFloat durationPerFrame = duration / (actualFramesNeeded*1.0);
    self.widthPerSecond = contentViewFrameWidth / duration;
    
    int prefreWidth = 0;
    for (int i=1; i<actualFramesNeeded; i++){
        
        CMTime time = CMTimeMake(i*durationPerFrame, 600);
        NSLog(@"Time:%f", i*durationPerFrame);
        
        CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        
        UIImage *videoScreen;
        if ([self isRetina]){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        
        
        CGRect currentFrame = tmp.frame;
        currentFrame.origin.x = i*picWidth;
        
        currentFrame.size.width = picWidth;
        prefreWidth += currentFrame.size.width;
        
        if( i == actualFramesNeeded-1){
            currentFrame.size.width-=6;
        }
        tmp.frame = currentFrame;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentView addSubview:tmp];
        });
        CGImageRelease(halfWayImage);
        
    }
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self notifyDelegate];
}

@end
