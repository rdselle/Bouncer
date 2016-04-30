//
//  BouncerViewController.m
//  Bouncer
//
//  Created by Robert Sellers on 5/5/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "BouncerViewController.h"
#import "Constants.h"
#import <CoreMotion/CoreMotion.h>

@interface BouncerViewController ( )

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIGravityBehavior *gravity;
@property (nonatomic, weak) UICollisionBehavior *collider;
@property (nonatomic, strong) UISnapBehavior *snap;
@property (nonatomic, strong) UISnapBehavior *touchSnap;
@property (nonatomic, strong) UIPushBehavior *push;
@property (nonatomic, weak) UIDynamicItemBehavior *elastic;
@property (nonatomic, weak) UIDynamicItemBehavior *density;
@property (nonatomic, strong) CMMotionManager *motionManager;

@property NSMutableArray *blockArray;

@property BOOL smallBlocksImmune;
@property CGPoint previousCenter;

@end

@implementation BouncerViewController

typedef enum{
    ui_view,
    block_view,
    unknown
} ViewType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.blockArray = [NSMutableArray arrayWithArray:@[ ]];
    
    self.view.userInteractionEnabled = YES;
    self.smallBlocksImmune = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startGame];
}

-(UIDynamicAnimator *)animator{
    if(!_animator){
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return _animator;
}

-(UICollisionBehavior *)collider{
    if(!_collider){
        UICollisionBehavior *collider = [[UICollisionBehavior alloc] init];
        collider.translatesReferenceBoundsIntoBoundary = YES;
        collider.collisionDelegate = self;
        [self.animator addBehavior:collider];
        _collider = collider;
    }
    return _collider;
}

-(UIGravityBehavior *)gravity{
    if(!_gravity){
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] init];
        [self.animator addBehavior:gravity];
        _gravity = gravity;
    }
    return _gravity;
}

-(UIDynamicItemBehavior *)elastic{
    if(!_elastic){
        UIDynamicItemBehavior *elastic = [[UIDynamicItemBehavior alloc] init];
        elastic.elasticity = ELASTICITY;
        [self.animator addBehavior:elastic];
        _elastic = elastic;
    }
    return _elastic;
}

-(UIDynamicItemBehavior *)density{
    if(!_density){
        UIDynamicItemBehavior *density = [[UIDynamicItemBehavior alloc] init];
        density.density = SMALL_BLOCK_DENSITY;
        [self.animator addBehavior:density];
        _density = density;
    }
    return _density;
}

-(CMMotionManager *)motionManager{
    if(!_motionManager){
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.1;
    }
    return _motionManager;
}

-(void)startGame{
    if(![self.blockArray count]){
        [self createNewBlockAt:initialCenter];
    }
    
    if(!self.motionManager.isAccelerometerActive){
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                                     CGFloat x = (accelerometerData.acceleration.x / 5);
                                                     CGFloat y = (accelerometerData.acceleration.y / 5);
                                                     switch([[UIApplication sharedApplication] statusBarOrientation]){
                                                         case UIInterfaceOrientationLandscapeRight:
                                                             self.gravity.gravityDirection = CGVectorMake(-y, -x);
                                                             break;
                                                         case UIInterfaceOrientationLandscapeLeft:
                                                             self.gravity.gravityDirection = CGVectorMake(y, x);
                                                             break;
                                                         case UIInterfaceOrientationPortrait:
                                                             self.gravity.gravityDirection = CGVectorMake(x, -y);
                                                             break;
                                                         case UIInterfaceOrientationPortraitUpsideDown:
                                                             self.gravity.gravityDirection = CGVectorMake(-x, y);
                                                             break;
                                                         case UIInterfaceOrientationUnknown:
                                                             self.gravity.gravityDirection = CGVectorMake(0.0, 0.0);
                                                             break;
                                                     }
                                                 }];
    }
}

#pragma mark - block creation methods

-(void)createNewBlockAt:(CGPoint) location{
    BlockView *newBlock = [self addBlockAtLocation:location];
    newBlock.delegate = self;
    [self.collider addItem:newBlock];
    [self.gravity addItem:newBlock];
    [self.elastic addItem:newBlock];
    [self.blockArray addObject:newBlock];
    
    self.snap = [[UISnapBehavior alloc] initWithItem:[self.blockArray lastObject] snapToPoint:initialCenter];
    self.snap.damping = SNAP_DAMPING;
    [self.animator addBehavior:self.snap];
}

-(BlockView *)addBlockAtLocation:(CGPoint) location{
    CGRect blockFrame = CGRectMake(location.x - blockSize.width / 2, location.y - blockSize.height / 2, blockSize.width, blockSize.height);
    BlockView *block = [[BlockView alloc] initWithFrame:blockFrame];
    block.backgroundColor = [self randomColor];
    [self.view addSubview:block];
    return block;
}

-(BOOL)shouldCreateNewBlock:(CGPoint) blockCenter and:(CGPoint) touch{
    float result = [self pythagoreanTheorem:CGPointMake((touch.x - blockCenter.x), (touch.y - blockCenter.y))];
    return result > DISTANCE_FOR_NEW_BLOCK ? YES : NO;
}

#pragma mark - BlockView delegate methods

-(void)addAttachForView:(BlockView *) view withTouches:(NSSet *) touches{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.view];
    
    self.touchSnap = [[UISnapBehavior alloc] initWithItem:view snapToPoint:location];
    [self.animator addBehavior:self.touchSnap];
}

-(void)updatePositionForView:(BlockView *)view withTouches:(NSSet *)touches{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.view];
    
    [self.animator removeBehavior:self.touchSnap];
    self.touchSnap = [[UISnapBehavior alloc] initWithItem:view snapToPoint:location];
    [self.animator addBehavior:self.touchSnap];
    
    if(view.latestBlock){
        if([self shouldCreateNewBlock:view.center and:location]){
            view.latestBlock = NO;
            [self.animator removeBehavior:self.snap];
            
            [self createNewBlockAt:view.center];
        }
    }
}

-(void)removeAttach{
    [self.animator removeBehavior:self.touchSnap];
}

#pragma mark - collision handling

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p{
    ViewType itemType = [self determineClass:item];
    ViewType item2Type = [self determineClass:item2];
    
    if(itemType == block_view && item2Type == block_view){
        BlockView *localBlock = (BlockView *) item;
        BlockView *localBlock2 = (BlockView *) item2;
        
        float itemSpeed = [self pythagoreanTheorem:[self.elastic linearVelocityForItem:item]];
        float item2Speed = [self pythagoreanTheorem:[self.elastic linearVelocityForItem:item2]];
        
        if(!(localBlock.latestBlock || localBlock2.latestBlock)){
            if(itemSpeed > item2Speed + SPEED_DIFFERENTIAL_OF_DESTRUCTION){
                [self destroyBlock:localBlock2 collisionBehavior:behavior];
            }else if(itemSpeed + SPEED_DIFFERENTIAL_OF_DESTRUCTION < item2Speed){
                [self destroyBlock:localBlock collisionBehavior:behavior];
            }
        }
    //above if condition will catch cases where both items are block views- these cases check if just one of the items is a block view
    }else if(itemType == block_view){
        [self destroyView:(UIView *) item2 collisionBehavior:behavior];
    }else if(item2Type == block_view){
        [self destroyView:(UIView *) item collisionBehavior:behavior];
    }else{
        //if both items are not a block view, let the animator handle the collision and do nothing extra
    }
}

-(void)destroyBlock:(BlockView *) block collisionBehavior:(UICollisionBehavior *) behavior{
    NSArray *viewsToAdd = [block split];
    [behavior removeItem:block];
    [self.blockArray removeObject:block];
    
    [self addItemsToAnimatorBehaviors:viewsToAdd];
}

-(void)destroyView:(UIView *) view collisionBehavior:(UICollisionBehavior *) behavior{
    if(!self.smallBlocksImmune){
        [view removeFromSuperview];
        [behavior removeItem:view];
        [self.density removeItem:view];
        [self.gravity removeItem:view];
        [self.elastic removeItem:view];
    }
}

#pragma mark - set up split BlockViews

-(void)addItemsToAnimatorBehaviors:(NSArray *) itemsToAdd{
    for(UIView *item in itemsToAdd){
        [self.collider addItem:item];
        [self.gravity addItem:item];
        [self.elastic addItem:item];
        [self.density addItem:item];
        
        [self configurePushFor:item];
    }
    
    self.smallBlocksImmune = YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, TIME_DIFFERENTIAL_OF_DESTRUCTION * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue( ), ^(void){
        self.smallBlocksImmune = NO;
    });
}

-(void)configurePushFor:(UIView *) item{
    float angle = (arc4random( ) % 360) * M_PI / 180.0;
    float magnitude = (((arc4random( ) % 2) + 0.5) *SMALL_BLOCK_DENSITY);
    
    self.push = [[UIPushBehavior alloc] initWithItems:@[item] mode:UIPushBehaviorModeInstantaneous];
    [self.push setAngle:angle magnitude:magnitude];
    [self.animator addBehavior:self.push];
    [self.push setActive:YES];
}

#pragma mark - miscellaneous

-(UIColor *)randomColor{
    //the background is white.  RGB values are all capped at 200 to keep blocks from being too bright to see
    CGFloat red = arc4random( ) % 200 / 200.0;
    CGFloat green = arc4random( ) % 200 / 200.0;
    CGFloat blue = arc4random( ) % 200 / 200.0;
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return newColor;
}

-(ViewType)determineClass:(id<UIDynamicItem>) item{
    if([item isKindOfClass:[BlockView class]]){
        return block_view;
    }else if([item isKindOfClass:[UIView class]]){
        return ui_view;
    }else{
        return unknown;
    }
}

-(float)pythagoreanTheorem:(CGPoint) p{
    return sqrtf((powf(p.x, 2) + powf(p.y, 2)));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
