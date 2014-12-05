//
//  NFViewVolume.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFProtocols.h"

//
// TODO: should import NFCamera in the header, use in m file (will then need
//       a generic bindCameraResource:(id)resource method to set the NFCamera property
//
#import "NFCamera.h"


@interface NFViewVolume : NSObject <NFObserverProtocol>

@property (nonatomic, assign) BOOL dirty;

//
// TODO: properties with overridden setters for setting the vertical FOV, aspect ratio,
//       near Z, and far Z
//


//
// the nearPlane and farPlane should be set in the view volume since they are likely to
// to set procedurally (within a given bounds set by some engine config) based on what is
// happening internally in order to maximize the accuracy of the depth buffer
//

@property (nonatomic, assign) float nearPlane;
@property (nonatomic, assign) float farPlane;

//
// TODO: override the setter to update the projection matrix
//
@property (nonatomic, strong) NFCamera *activeCamera;



// NFViewVolume is going to have to be more than just a container for pushing
// popping matrices


// calculate projection matrix here

// view matrice will still be pushed in to build a transformation hierarchy




@property (nonatomic, assign, readonly) GLKMatrix4 view;
@property (nonatomic, assign, readonly) GLKMatrix4 projection;

- (void) pushViewMatrix:(GLKMatrix4)mat;

// will clear the matrix stack and set the provided matrix as the base matrix on the stack
- (void) overrideViewTransformWithMatrix:(GLKMatrix4)mat;



//
// TODO: remove these methods, projection matrix will get update via NFCamera
//       and the near/far plane properties
//
- (void) pushProjectionMatrix:(GLKMatrix4)mat;
- (void) overrideProjectionTransformWithMatrix:(GLKMatrix4)mat;



//
// TODO: rename to update and pull from the activeCamera if dirty flag has been set
//       and update projection matrix getter to pull from active camera if dirty as well
//

// this method will manually trigger an update to the view volume transforms it can safely
// not be called and the matrices will be updated when they are used next if they are dirty
- (void) updateAllTransforms;



// for NFObserverProtocol
- (void) notifyOfStateChange;


@end
