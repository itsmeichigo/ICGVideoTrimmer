//
//  ICGVideoTrimmerView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGVideoTrimmerView.h"
#import "ICGLeftThumbView.h"

@interface ICGVideoTrimmerView()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@property (strong, nonatomic) ICGLeftThumbView *leftThumb;

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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
    [self.contentView setClipsToBounds:YES];
    [self.scrollView setContentSize:self.contentView.frame.size];
    [self.scrollView addSubview:self.contentView];
    
    [self addFrames];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    [topBorder setBackgroundColor:self.themeColor];
    [self addSubview:topBorder];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1)];
    [bottomBorder setBackgroundColor:self.themeColor];
    [self addSubview:bottomBorder];
    
//    self.leftThumb = [[ICGLeftThumbView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height) color:[UIColor redColor]];
//    self.leftThumb.contentMode = UIViewContentModeLeft;
//    self.leftThumb.userInteractionEnabled = YES;
//    self.leftThumb.clipsToBounds = YES;
//    self.leftThumb.backgroundColor = [UIColor clearColor];
//    self.leftThumb.layer.borderWidth = 0;
//    [self addSubview:self.leftThumb];
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
    
    CGFloat contentViewFrameWidth = (duration / self.maxLength) * screenWidth;
    [self.contentView setFrame:CGRectMake(0, 0, contentViewFrameWidth, CGRectGetHeight(self.contentView.frame))];
    [self.scrollView setContentSize:self.contentView.frame.size];
    NSInteger minFramesNeeded = screenWidth / picWidth + 1;
    actualFramesNeeded =  (duration / self.maxLength) * minFramesNeeded;
    
    CGFloat durationPerFrame = duration / (actualFramesNeeded*1.0);
    
    int prefreWidth=0;
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

@end
