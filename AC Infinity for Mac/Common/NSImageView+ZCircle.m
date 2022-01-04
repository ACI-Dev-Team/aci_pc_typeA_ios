//
//  NSImageView+_2.m
//  AC Infinity for Mac
//
//  Created by cooltron on 2021/7/5.
//

#import "NSImageView+ZCircle.h"


@implementation NSImageView (ZCircle)

- (void)setZc_Center:(CGPoint)zc_Center
{
   // CGRect frame = self.frame;
    CGRect frame = CGRectMake(zc_Center.x - self.frame.size.width/2, zc_Center.y - self.frame.size.height/2, self.frame.size.width, self.frame.size.height);
    self.frame = frame;
}

- (CGPoint)zc_Center
{
    return CGPointMake(self.frame.origin.x+self.frame.size.width/2., self.frame.origin.y+self.frame.size.height/2.);
}


@end
