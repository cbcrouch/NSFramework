//
//  NFViewVolume.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFProtocols.h"
#import "NFCamera.h"


@interface NFViewVolume : NSObject <NFObserverProtocol>

//
// TODO: properties with overridden setters for setting the vertical FOV, aspect ratio,
//       near Z, and far Z
//

//
// the nearPlane and farPlane should be set in the view volume since they are likely to
// to set procedurally (within a given bounds set by some engine config) based on what is
// happening internally in order to maximize the accuracy of the depth buffer
//
//@property (nonatomic, assign) float nearPlane;
//@property (nonatomic, assign) float farPlane;


//
// TODO: need a property to store an assign camera to the view volume
//
//@property (nonatomic, strong) NFCamera *boundCamera;


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

// for NFObserverProtocol
- (void) notify;

@end
