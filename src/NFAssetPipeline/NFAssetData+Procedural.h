//
//  NFAssetData+Procedural.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"

@interface NFAssetData (Procedural)


//
// TODO: the following two methods could be moved to an NFAssetData (Debug) module once the
//       procedural category starts to expand
//
- (void) createGridOfSize:(NSInteger)size; // add parameters to specify size of X axis and Z axis
- (void) createAxisOfSize:(NSInteger)size;


- (void) createPlaneOfSize:(NSInteger)size;


//
// TODO: should also generate an icoshedron sphere (icosphere)
//

- (void) createUVSphereWithRadius:(float)radius withStacks:(int)stacks withSlices:(int)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat;
- (void) createCylinderWithRadius:(float)radius ofHeight:(float)height withSlices:(NSInteger)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat;
- (void) createConeWithRadius:(float)radius ofHeight:(float)height withSlices:(NSInteger)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat;



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
