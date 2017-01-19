//
//  NFAssetUtils.h
//  NSFramework
//
//  Created by ccrouch on 2/26/15.
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"
#import "NFRResources.h"


@interface NFAssetUtils : NSObject


//
// TODO: refactor these two WFObject methods to operate on an NFAssetData object
//
//- (void) calculateTextureCoordinates;
//- (void) calculateNormals;


+ (NFFace_t) calculateFaceWithPoints:(NFVertex_t *)vertices withIndices:(GLushort [3])indices;

+ (GLKVector4) calculateAreaWeightedNormalOfIndex:(GLushort)index withFaces:(NSArray *)faceArray;
+ (GLKVector4) calculateAngleWeightedNormalOfVertex:(GLfloat[4])vertex withFaces:(NSArray *)faceArray;


//
// TODO: determine feasibility of moving this method to NFAssetLoader
//
+ (NFRDataMap *) parseTextureFile:(NSString *)file flipVertical:(BOOL)flip;


@end
