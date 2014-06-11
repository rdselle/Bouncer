//
//  BlockView.h
//  Bouncer
//
//  Created by Robert Sellers on 5/20/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlockView;

@protocol BlockViewDelegate

-(void)addAttachForView:(BlockView *) view withTouches:(NSSet *) touches;
-(void)updatePositionForView:(BlockView *) view withTouches:(NSSet *) touches;
-(void)removeAttach;

@end

@interface BlockView : UIView

@property (nonatomic, weak) id <BlockViewDelegate> delegate;

//marks the block that is anchored at the top of the screen
@property BOOL latestBlock;

-(NSArray *)split;

@end
