//
//  NFAssetData+Procedural.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"

@interface NFAssetData (Procedural)

- (void) createGridOfSize:(NSInteger)size; // add parameters to specify size of X axis and Z axis

- (void) createAxisOfSize:(NSInteger)size;
- (void) loadAxisSurface:(NFSurfaceModel *)surface;

- (void) createPlaneOfSize:(NSInteger)size;

+ (NFFace_t) calculateFaceWithPoints:(NFVertex_t *)vertices withIndices:(GLushort *)indices;
+ (GLKVector4) calculateAreaWeightedNormalOfIndex:(GLushort)index withFaces:(NSArray *)faceArray;
+ (GLKVector4) calculateAngleWeightedNormalOfVertex:(GLfloat[4])vertex withFaces:(NSArray *)faceArray;

//
// TODO: use the following geometries to visualize lights
//
// point light == sphere
// directional light == cylinder
// spot light == cone
//
// for cone and cylinder only fully light the face that is emitting the light
// while the remaining sides should still be the same color just grayed out
//

@end
