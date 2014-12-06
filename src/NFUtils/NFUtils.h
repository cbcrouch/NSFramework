//
//  NFUtils.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: "the abstime unit is equal to the length of one bus cycle" according to Mach documentation

typedef uint64_t MACH_TIME;

#ifdef DEBUG
#define GET_MACH_TIME() CVGetCurrentHostTime() // returns MACH_TIME
#else
#define GET_MACH_TIME() // no-op when building a release version
#endif

#ifdef DEBUG
#define LOG_MACH_TIME_DELTA(TIME_STAMP) NSLog(@"time diff: %f micro seconds", \
    (CVGetCurrentHostTime() - TIME_STAMP) / CVGetHostClockFrequency())
#else
#define LOG_MACH_TIME_DELTA() // no-op when building a release version
#endif


static NSArray * (^convertCfloatArrayToNS)(float[3]) = ^ NSArray * (float triplet[3]) {
    NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
    NSNumber *tempNum;
    for (int i=0; i<3; ++i) {
        tempNum = [NSNumber numberWithFloat:triplet[i]];
        [tempArray addObject:tempNum];
    }
    return [[tempArray copy] autorelease];
};


//
// TODO: NFMotionVector implementation should be moved to the animation module
//

//@interface NFMotionVector : NSObject
//@property(nonatomic, assign) GLKVector4 vector;
//@property(nonatomic, assign) NSInteger rate;
//@end


@interface NFUtils : NSObject

@end