//
//  ICGRulerView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/25/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGRulerView.h"

@implementation ICGRulerView

- (instancetype)initWithFrame:(CGRect)frame widthPerSecond:(CGFloat)width
{
    self = [super initWithFrame:frame];
    if (self) {
        _widthPerSecond = width;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat leftMargin = 0;
    CGFloat topMargin = 0;
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat minorTickSpace = self.widthPerSecond;
    int multiple = 5;             
    CGFloat majorTickLength = 10;
    CGFloat minorTickLength = 5;
    
    CGFloat baseY = topMargin + height;
    CGFloat minorY = baseY - minorTickLength;
    CGFloat majorY = baseY - majorTickLength;
    
    int step = 0;
    for (CGFloat x = leftMargin; x <= (leftMargin + width); x += minorTickSpace) {
        CGContextMoveToPoint(context, x, baseY);
        
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.5].CGColor);
        if (step % multiple == 0) {
            CGContextFillRect(context, CGRectMake(x, majorY, 1.75, majorTickLength));
            
            UIFont *font = [UIFont systemFontOfSize:11];
            UIColor *textColor = [UIColor colorWithWhite:1 alpha:0.5];
            NSDictionary *stringAttrs = @{NSFontAttributeName:font, NSForegroundColorAttributeName:textColor};
            
            NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@":%02i", step] attributes:stringAttrs];
            if (step == 0) {
                [attrStr drawAtPoint:CGPointMake(x, majorY - 15)];
            } else {
                [attrStr drawAtPoint:CGPointMake(x-5, majorY - 15)];
            }
            
            
        } else {
            CGContextFillRect(context, CGRectMake(x, minorY, 1.0, minorTickLength));
        }
        
        step++;
    }

}

@end
