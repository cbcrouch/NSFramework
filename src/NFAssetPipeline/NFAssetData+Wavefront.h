//
//  NFAssetData+Wavefront.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"
#import "NFWavefrontObj.h"

@interface NFAssetData (Wavefront)


- (void) setNumberOfSubsets:(NSInteger)numSubsets;


// subsets should just be indices into the primary data (vertices, texture coordinates, normals, etc.)

// in this case the VBO would be the complete data set of vertices, normals, texture coordinates and the
// subset would then be the index buffer (EBO)

- (void) addSubsetWithIndices:(NSMutableArray *)indices ofObject:(WFObject *)wfObj atIndex:(NSUInteger)idx;

@end
