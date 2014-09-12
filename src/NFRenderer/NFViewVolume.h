//
//  NFViewVolume.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@interface NFViewVolume : NSObject

@property (nonatomic, assign, readonly) GLKMatrix4 view;
@property (nonatomic, assign, readonly) GLKMatrix4 projection;

- (void) pushViewMatrix:(GLKMatrix4)mat;
- (void) pushProjectionMatrix:(GLKMatrix4)mat;

// these methods will clear the matrix stack for the associated transform and set
// the provided matrix as the base matrix on the stack
- (void) overrideViewTransformWithMatrix:(GLKMatrix4)mat;
- (void) overrideProjectionTransformWithMatrix:(GLKMatrix4)mat;

// this method will manually trigger an update to the view volume transforms it can safely
// not be called and the matrices will be updated when they are used next if they are dirty
- (void) updateAllTransforms;

@end
