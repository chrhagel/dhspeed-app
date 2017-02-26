//
//  MotionServices.m
//  BikeTrax
//
//  Created by blair on 2/26/17.
//  Copyright © 2017 Blair, Rick. All rights reserved.
//

#import "MotionServices.h"
#import <CoreMotion/CoreMotion.h>

@interface MotionServices ()

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (assign) float oldX;
@property (assign) float oldY;
@property (assign) float oldZ;
@property  (strong, nonatomic) NSString *direction;
@property (assign) NSTimeInterval oldTime;
@property (assign) NSTimeInterval lastTime;
-(void) addAccelData:(CMAcceleration)accel;
-(bool) didSlap:(CMAccelerometerData*)accelData;



@end

@implementation MotionServices

//Singleton

static MotionServices *sharedService = nil;
static dispatch_once_t onceToken;

+(MotionServices *)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedService= [self new];
        
    });
    return sharedService;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _oldX = 0.0;
        _oldY = 0.0;
        _oldZ = 0.0;
        _oldTime  = 0.0;
        _lastTime = 0.0;
    }
    return self;
}


//LowPass Filter
-(void) addAccelData:(CMAcceleration)accel
{
    double alpha = 0.1;
    _oldX = accel.x - ((accel.x * alpha) + (_oldX *(1.0 - alpha)));
    _oldY = accel.y - ((accel.y * alpha) + (_oldY *(1.0 - alpha)));
    _oldZ = accel.z - ((accel.z * alpha) + (_oldZ *(1.0 - alpha)));
    
}

-(void) startUpdating
{
        if(_motionManager == nil)
        {
            self.motionManager = [[CMMotionManager alloc] init];
        }
    NSLog(@"Start Updating for SLAP ***************");
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self didSlap:accelerometerData];
                                                 if(error){
                                                     
                                                     NSLog(@"***** Error in starting Slap Detect: %@", error);
                                                 }
                                             }];
}

-(void) stopUpdating
{
    [_motionManager stopDeviceMotionUpdates];
}

- (bool) didSlap:(CMAccelerometerData *)accelData
{
    bool rval = NO;
    CMAcceleration accel = accelData.acceleration;
    [self addAccelData:accel];
    
    float z = _oldZ;
    float ot = _oldTime;
    float thresh = 1.0;
    if((z < -thresh) || (z > thresh))
    {
        NSLog(@"Something Happened on Z");
    }
    
    if(z < -thresh)
    {
        if(accelData.timestamp - _oldTime > 0.5 || _lastTime ==1)
        {
            _oldTime = accelData.timestamp;
            _lastTime  = -1;
            if(accelData.timestamp - ot > .5)
            {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kSlapNotification
                 object:self];
                NSLog(@"@@@ _lastTime -1 %f ",accelData.timestamp - ot);
            }
        }
    }
    
    if(z > thresh)
    {
        if(accelData.timestamp - _oldTime > 0.5 || _lastTime == -1)
        {
            _oldTime = accelData.timestamp;
            _lastTime  = 1;
            if(accelData.timestamp - ot > .5)
            {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kSlapNotification
                 object:self];
                 NSLog(@"### _lastTime 1 %f ",accelData.timestamp - ot);
            }
            
        }
    }
    
    
    return rval;
}


@end
