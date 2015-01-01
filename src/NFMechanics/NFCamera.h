//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFUtils.h"


//
// TODO: rename enum NF_CAMERA_TRANSLATION_STATE or something similar
//
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
// TODO: define NFMotionVector in NFRUtils ?? or will it be NFCamera specific ??
//
@interface NFMotionVector : NSObject
@property (nonatomic, assign) GLKVector4 currentValue;
@property (nonatomic, assign) GLKVector4 modifier;
@property (nonatomic, assign) MACH_TIME updateRate;
@end


@interface NFCamera : NSObject

//
// TODO: allow user control to set the horizontal FOV which will modify the aspect ratio
//
//@property (nonatomic, assign) float hFOV;
@property (nonatomic, assign) float vFOV; // vertical FOV in radians

// hFOV = 2 * arctan(tan(vFOV/2) * aspectRatio)
// vFOV = 2 * arctan(tan(hFOV/2) * 1/aspectRatio)


@property (nonatomic, assign, readonly) GLKVector3 position;
@property (nonatomic, assign, readonly) GLKVector3 target;
@property (nonatomic, assign, readonly) GLKVector3 up;

@property (nonatomic, assign) float nearPlaneDistance;
@property (nonatomic, assign) float farPlaneDistance;
@property (nonatomic, assign) float aspectRatio;


// component values is what will be applied as a translation based on the camera state
@property (nonatomic, assign) GLKVector4 translationSpeed;


- (instancetype) initWithPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up;


//
// TODO: pass in microsecond step
//
- (void) step:(NSUInteger)delta;

- (void) pushMotionVector:(NFMotionVector *)motionVector;
- (void) clearMotionVectors;


//
// TODO: should rename this to something like setTranslationState
//
- (void) setState:(CAMERA_STATE)state;


- (void) resetTarget;
- (void) resetPosition; // TODO: needs a better name resetToInitialValues ??

- (void) setPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up;

- (void) setShapeWithVerticalFOV:(float)vAngle withAspectRatio:(float)aspect
                    withNearDist:(float)nearDist withFarDist:(float)farDist;


// NOTE: translations are relative movements to the camera's current position
- (void) translateWithVector3:(GLKVector3)vec;
- (void) translateWithDeltaX:(float)delX withDeltaY:(float)delY withDeltaZ:(float)delZ;

//
// TODO: while the sparse documentation online does claim that the UVN camera system will
//       prevent gimbal lock, should really prove it mathematically
//
- (void) roll:(float)angle;
- (void) pitch:(float)angle;
- (void) yaw:(float)angle;

- (GLKMatrix4) getViewMatrix;
- (GLKMatrix4) getProjectionMatrix;

@end
