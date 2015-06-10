//
//  NFAssetUtils.h
//  NSFramework
//
//  Created by cbcrouch on 2/26/15.
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"


@interface NFAssetUtils : NSObject

+ (NFFace_t) calculateFaceWithPoints:(NFVertex_t *)vertices withIndices:(GLushort [3])indices;

+ (GLKVector4) calculateAreaWeightedNormalOfIndex:(GLushort)index withFaces:(NSArray *)faceArray;
+ (GLKVector4) calculateAngleWeightedNormalOfVertex:(GLfloat[4])vertex withFaces:(NSArray *)faceArray;

@end
