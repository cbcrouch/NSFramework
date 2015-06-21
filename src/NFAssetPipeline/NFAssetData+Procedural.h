//
//  NFAssetData+Procedural.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"

@interface NFAssetData (Procedural)


//
// TODO: the following two methods could be moved to an NFAssetData (Debug) module once the
//       procedural category starts to expand
//
- (void) createGridOfSize:(NSInteger)size; // add parameters to specify size of X axis and Z axis
- (void) createAxisOfSize:(NSInteger)size;

//
// TODO: eliminate the need for loadAxisSurface method by converting axis to use NFDebugVertex_t
//
- (void) loadAxisSurface:(NFSurfaceModel *)surface;



- (void) createPlaneOfSize:(NSInteger)size;


//
// TODO: should also generate an icoshedron sphere (icosphere)
//

- (void) createUVSphereWithRadius:(float)radius withStacks:(int)stacks withSlices:(int)slices;

//- (void) createCone:(float)radius ofHeight:(float)height;
//- (void) createCylinder:(float)radius ofHeight:(float)height;



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
