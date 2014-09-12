//
//  NFAssetData+Procedural.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"

@interface NFAssetData (Procedural)

//
// TODO: generate assets including a sphere, grid, default texture, axis guide, etc.
//


- (void) createGridOfSize:(NSInteger)size; // add parameters to specify size of X axis and Z axis

- (void) createAxisOfSize:(NSInteger)size;
- (void) loadAxisSurface:(NFSurfaceModel *)surface;

- (void) createPlaneOfSize:(NSInteger)size;



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
