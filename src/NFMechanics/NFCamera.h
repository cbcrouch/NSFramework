//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


typedef NS_ENUM(NSUInteger, CAMERA_STATE) {
    kCameraStateActFwd,
    kCameraStateNilFwd,
    kCameraStateActBack,
    kCameraStateNilBack,
    kCameraStateActRight,
    kCameraStateNilRight,
    kCameraStateActLeft,
    kCameraStateNilLeft
};

//
// TODO: will need to convert an NFCamera into an NFViewVolume
//

@interface NFCamera : NSObject

//
// TODO: should probably store near/far plane as well as vertical and horizontal field of view
//

//
// may want to move the nearPlane and farPlane into the view volume since they are likely to
// to set procedurally (within a given bounds set by some engine config) based on what is
// happening internally in order to maximize the accuracy of the depth buffer
//
//@property (nonatomic, assign) float nearPlane;
//@property (nonatomic, assign) float farPlane;

//@property (nonatomic, assign) float hFOV;
//@property (nonatomic, assign) float vFOV;

//
// TODO: will also need to store directional scalars (world space units per ms)
//

//@property (nonatomic, assign) GLKVector4 stateScalars;


//
// TODO: would also be ideal to store some kind of degrade units per ms value so
//       an additional vector could be applied to the camera which will degrade
//       back to zero over time (or until something else acts on it)
//

//- (void) pushMotionVector(NFMotionVector) motionVec;


@property (nonatomic, readonly, assign) GLKVector4 motionVector;
@property (nonatomic, readonly, assign) GLKVector4 position;

//
// TODO: provide a time delta which will be used as a motion vector scalar
//
- (void) step;

- (void) setState:(CAMERA_STATE) state;

@end
