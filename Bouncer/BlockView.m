//
//  BlockView.m
//  Bouncer
//
//  Created by Robert Sellers on 5/20/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "BlockView.h"
#import "Constants.h"

@implementation BlockView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _latestBlock = YES;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate addAttachForView:self withTouches:touches];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate updatePositionForView:self withTouches:touches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate removeAttach];
}

-(NSArray *)split{
    CGRect frame = self.frame;
    CGRect corner1 = CGRectMake(CGRectGetMinX(frame), frame.origin.y, blockSize.width / 2, blockSize.height / 2);
    CGRect corner2 = CGRectMake(CGRectGetMidX(frame), frame.origin.y, blockSize.width / 2, blockSize.height / 2);
    CGRect corner3 = CGRectMake(CGRectGetMinX(frame), CGRectGetMidY(frame), blockSize.width / 2, blockSize.height / 2);
    CGRect corner4 = CGRectMake(CGRectGetMidX(frame), CGRectGetMidY(frame), blockSize.width / 2, blockSize.height / 2);
    
    UIView *view1 = [[UIView alloc] initWithFrame:corner1];
    view1.backgroundColor = self.backgroundColor;
    [self.superview addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:corner2];
    view2.backgroundColor = self.backgroundColor;
    [self.superview addSubview:view2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:corner3];
    view3.backgroundColor = self.backgroundColor;
    [self.superview addSubview:view3];
    
    UIView *view4 = [[UIView alloc] initWithFrame:corner4];
    view4.backgroundColor = self.backgroundColor;
    [self.superview addSubview:view4];
    
    [self removeFromSuperview];
    
    return @[view1, view2, view3, view4];
}

@end
