//
//  ICGVideoTrimmerRightOverlayView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/19/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGRightThumbView.h"

@implementation ICGRightThumbView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _color = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Frames
    CGRect bubbleFrame = self.bounds;
    
    
    //// Rounded Rectangle Drawing
    CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(bubbleFrame), CGRectGetMinY(bubbleFrame), CGRectGetWidth(bubbleFrame), CGRectGetHeight(bubbleFrame));
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: CGSizeMake(3, 3)];
    [roundedRectanglePath closePath];
    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextRestoreGState(context);
    [self.color setFill];
    [roundedRectanglePath fill];
    
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0.45*CGRectGetWidth(bubbleFrame), 0.2*CGRectGetHeight(bubbleFrame)); //start at this point
    CGContextAddLineToPoint(context, 0.45*CGRectGetWidth(bubbleFrame), 0.8*CGRectGetHeight(bubbleFrame)); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
    
    
    //// Cleanup
    CGColorSpaceRelease(colorSpace);
    
}


@end
