//
//  Constants.h
//  Bouncer
//
//  Created by Robert Sellers on 5/29/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

//general settings

#define SNAP_DAMPING 0.5
#define ANCHOR_FREQUENCY 0.8
#define DISTANCE_FOR_NEW_BLOCK 110.0
#define SPEED_DIFFERENTIAL_OF_DESTRUCTION 250.0
#define TIME_DIFFERENTIAL_OF_DESTRUCTION 2.0
#define SMALL_BLOCK_DENSITY 3.0
#define ELASTICITY 0.5


@interface Constants : NSObject

extern const CGSize blockSize;
extern const CGPoint initialCenter;

@end
