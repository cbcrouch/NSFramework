//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFUtils.h"



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

// kCameraStateFwdRoll
// kCameraStateRevRoll

// kCameraStateFwdPitch
// kCameraStateRevPitch

// kCameraStateFwdYaw
// kCameraStateRevYaw


//
// TODO: add camera state control over roll/pitch/yaw, should ideally get
//       something better than the bit-mask implementation internally
//

// vec4 for translation values, vec3 for rotation values

// state is set by placing a value in the vector +/- or 0 if not set

// every step just updates everything (probably faster than checking each value for 0)



//
// TODO: define NFMotionVector in NFRUtils ?? or will it be NFCamera specific ??
//
@interface NFMotionVector : NSObject
@property (nonatomic, assign) GLKVector4 currentValue;
@property (nonatomic, assign) GLKVector4 modifier;
@property (nonatomic, assign) MACH_TIME updateRate;
@end




//
// TODO: implement alternative camera to test against UVN camera
//
@interface NFCameraAlt : NSObject

- (GLKMatrix4) getViewMatrix;
- (GLKMatrix4) getInverseViewMatrix;

- (float) getPitch;
- (float) getYaw;



- (void) lookDirection:(GLKVector3)lookDirection;

- (void) updateWithHorizontalAngle:(float)h_angle withVerticalAngle:(float)v_angle;



- (void) setViewParamsWithEye:(GLKVector3)eye withLook:(GLKVector3)look withUp:(GLKVector3)up;

@end




@interface NFCamera : NSObject

//
// TODO: allow user control to set the horizontal FOV which will modify the aspect ratio
//       (solve FOV equations for aspect ratio if at all possible/practical)
//

// hFOV = 2 * arctan(tan(vFOV/2) * aspectRatio)
// vFOV = 2 * arctan(tan(hFOV/2) * 1/aspectRatio)

//@property (nonatomic, assign) float hFOV;
@property (nonatomic, assign) float vFOV; // vertical FOV in radians


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


//
// TODO: merge pitch/yaw look direction controls in with the UVN camera implementation
//
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

//
// TODO: current roll/pitch/yaw angles are relative, add methods for setting
//       (and getting) absolute angles in world coordinates
//

- (GLKMatrix4) getViewMatrix;
- (GLKMatrix4) getProjectionMatrix;

@end
