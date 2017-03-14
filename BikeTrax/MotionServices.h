//
//  MotionServices.h
//  BikeTrax
//
//  Created by blair on 2/26/17.
//  Copyright © 2017 Blair, Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kSlapNotification @"MotionServicesSlapNotification"

@interface MotionServices : NSObject
@property (assign, atomic) float threshold;
@property (assign, nonatomic) float minZ;
@property (assign, nonatomic) float maxZ;

-(void)startUpdating;
-(void)stopUpdating;

+(MotionServices *)sharedInstance;
@end
