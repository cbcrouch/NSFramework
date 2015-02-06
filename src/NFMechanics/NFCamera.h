//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFUtils.h"


//typedef NS_ENUM(NSUInteger, CAMERA_TRANSLATION_STATE)

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
// TODO: keyboard control of camera look direction implemented similar
//       to the keyboard translation control
//
typedef NS_ENUM(NSUInteger, CAMERA_DIRECTION_STATE) {
    kCameraStateFwdRoll,
    kCameraStateRevRoll,
    kCameraStateFwdPitch,
    kCameraStateRevPitch,
    kCameraStateFwdYaw,
    kCameraStateRevYaw
};

//
// TODO: add camera state control over roll/pitch/yaw, should ideally get
//       something better than the bit-mask implementation internally
//

// - vec3 for translation values, vec3 for rotation values
// - state is set by placing a value in the vector +/- or 0 if not set
// - every step just updates everything (probably faster than checking each value for 0)

//
// TODO: when key press is up start decrement value by a small fixed amount until
//       the value reaches 0, this will prevent very hard stops (value and whether it
//       even gets applied should be adjustable)
//



@interface NFViewVolume : NSObject

@property (nonatomic, assign, readonly) GLKMatrix4 projection;

//
// TODO: don't use the FOV properites yet as they are not fully implemented
//
// field of view measurements are in radians
@property (nonatomic, assign) float hFOV;
@property (nonatomic, assign) float vFOV;

@property (nonatomic, assign) float aspectRatio;

@property (nonatomic, assign) float nearPlaneDistance;
@property (nonatomic, assign) float farPlaneDistance;

- (void) setShapeWithVerticalFOV:(float)vAngle withAspectRatio:(float)aspect
                    withNearDist:(float)nearDist withFarDist:(float)farDist;

@end


@interface NFCamera : NSObject

@property (nonatomic, assign, readonly) GLKMatrix4 viewMatrix;

@property (nonatomic, assign, readonly) GLKVector3 eye;
@property (nonatomic, assign, readonly) GLKVector3 look;
@property (nonatomic, assign, readonly) GLKVector3 up;

//
// TODO: would it make more sense to rename the horizontal and veritcal angles to
//       yaw and pitch respectively ??
//

//
// TODO: if using these properties then override the setters to update the view matrix
//
//@property (nonatomic, assign) float lookHorizontal;
//@property (nonatomic, assign) float lookVertical;

- (void) setLookHorizontalAngle:(float)h_angle verticalAngle:(float)v_angle;
- (void) setEyePosition:(GLKVector3)eye withLookVector:(GLKVector3)look withUpVector:(GLKVector3)up;

//
// TODO: add the translation logic directly to the camera or possibly in another
//       object (e.g. NFTranslationControl ??) which could be used to simply
//       move around other entities
//

@end



/*
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



//
// TODO: should rename this to something like setTranslationState
//
- (void) setState:(CAMERA_STATE)state;


- (void) resetTarget; // TODO: needs a better name - resetLookDirection ??
- (void) resetPosition; // TODO: needs a better name - resetToInitialValues ??


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
// TODO: current roll/pitch/yaw angles are relative, add methods for setting (and getting) absolute angles
//
- (void) roll:(float)angle;
- (void) pitch:(float)angle;
- (void) yaw:(float)angle;


- (GLKMatrix4) getViewMatrix;
- (GLKMatrix4) getProjectionMatrix;

@end
*/
