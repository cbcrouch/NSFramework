//
//  NFCamera.h
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
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

    //kCameraStateActUp,
    //kCameraStateNilUp,
    //kCameraStateActDown,
    //kCameraStateNilDown
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

@property (nonatomic, assign, readonly) float yaw;
@property (nonatomic, assign, readonly) float pitch;


- (instancetype) initWithEyePosition:(GLKVector3)eye withLookVector:(GLKVector3)look withUpVector:(GLKVector3)up NS_DESIGNATED_INITIALIZER;

// NOTE: yaw and pitch angles are absolute angles in spherical coordinates
- (void) setLookWithYaw:(float)yawAngle withPitch:(float)pitchAngle;

//
// TODO: add support for rolling the camera
//


//
// TODO: add the translation logic directly to the camera or possibly in another
//       object (e.g. NFTranslationControl ??) which could be used to simply
//       move around other entities
//
- (void) step:(float)secsElapsed;
- (void) setTranslationState:(CAMERA_STATE)state;


- (void) resetLookDirection;
- (void) resetState;

// NOTE: function will preserve the cameras current state, this state will be
//       what is used on the next resetLookDirection and resetState calls
- (void) saveState;

@end
