//
//  ICGVideoTrimmerView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGVideoTrimmerView.h"

@interface ICGVideoTrimmerView()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

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
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(scrollView.frame))];
    [self.contentView setClipsToBounds:YES];
    [scrollView addSubview:self.contentView];
    
    [self addFrames];
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
    
    if (self.maxLength == 0) {
        self.maxLength = 15;
    }
    
    CGFloat duration = CMTimeGetSeconds([self.asset duration]);
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger actualFramesNeeded;
    if (duration > self.maxLength) {
        CGFloat contentViewFrameWidth = (duration / self.maxLength) * screenWidth;
        [self.contentView setFrame:CGRectMake(0, 0, contentViewFrameWidth, CGRectGetHeight(self.contentView.frame))];
        NSInteger minFramesNeeded = screenWidth / picWidth + 1;
        actualFramesNeeded =  (duration / self.maxLength) * minFramesNeeded;
    } else {
        actualFramesNeeded = screenWidth / picWidth + 1;
    }
    
    CGFloat durationPerFrame = duration / (actualFramesNeeded*1.0);
    
    int prefreWidth=0;
    for (int i=1; i<actualFramesNeeded; i++){
        
        CMTime time = CMTimeMake(i*durationPerFrame, 600);
        
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
        
        currentFrame.size.width=picWidth;
        prefreWidth+=currentFrame.size.width;
        
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

@end
