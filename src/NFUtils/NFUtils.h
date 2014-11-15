//
//  NFUtils.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFAssetData.h"

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


@interface NFUtils : NSObject

//
// NOTE: this method will use the first three values from indices to access the vertices memory
//
+ (NFFace_t) calculateFaceWithPoints:(NFVertex_t *)vertices withIndices:(GLushort *)indices;

+ (GLKVector4) calculateAreaWeightedNormalOfIndex:(GLushort)index withFaces:(NSArray *)faceArray;
+ (GLKVector4) calculateAngleWeightedNormalOfVertex:(GLfloat[4])vertex withFaces:(NSArray *)faceArray;

@end
