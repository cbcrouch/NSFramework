//
//  NFAssetData+Wavefront.h
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"
#import "NFWavefrontObj.h"

@interface NFAssetData (Wavefront)

- (void) setNumberOfSubsets:(NSInteger)numSubsets;
- (void) addSubsetWithIndices:(NSMutableArray *)indices ofObject:(WFObject *)wfObj atIndex:(NSUInteger)idx;

@end
