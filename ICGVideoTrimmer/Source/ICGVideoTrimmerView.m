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
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:scrollView.frame];
    [scrollView addSubview:self.contentView];
    
    [self addFrames];
}

- (void)addFrames
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    
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
    NSInteger minFramesNeeded = screenWidth / picWidth + 1;
    NSInteger actualFramesNeeded =  (duration / self.maxLength) * minFramesNeeded;
    
    NSMutableArray *times = [[NSMutableArray alloc] init];
    CGFloat durationPerFrame = duration / (actualFramesNeeded*1.0);
    for (int i=1; i<actualFramesNeeded; i++) {
        CMTime time = CMTimeMake(i*durationPerFrame, 600);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    __block int i = 1;
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result, NSError *error)
     {
         NSString *requestedTimeString = (NSString *)
         CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
         NSString *actualTimeString = (NSString *)
         CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
         NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
         
         if (result == AVAssetImageGeneratorSucceeded) {
             UIImage *videoScreen;
             if ([self isRetina]){
                 videoScreen = [[UIImage alloc] initWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
             } else {
                 videoScreen = [[UIImage alloc] initWithCGImage:image];
             }
             
             
             UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
             
             int all = (i+1)*tmp.frame.size.width;
             
             
             CGRect currentFrame = tmp.frame;
             currentFrame.origin.x = i*currentFrame.size.width;
             if (all > self.contentView.frame.size.width){
                 int delta = all - self.contentView.frame.size.width;
                 currentFrame.size.width -= delta;
             }
             tmp.frame = currentFrame;
             i++;
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.contentView addSubview:tmp];
             });
         }
         
         if (result == AVAssetImageGeneratorFailed) {
             NSLog(@"Failed with error: %@", [error localizedDescription]);
         }
         if (result == AVAssetImageGeneratorCancelled) {
             NSLog(@"Canceled");
         }
     }];
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}

@end
