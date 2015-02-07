//
//  NFCamera.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFCamera.h"


#define FORWARD_BIT 0x01
#define BACK_BIT    0x02
#define LEFT_BIT    0x04
#define RIGHT_BIT   0x08

#define X_IDX 0
#define Y_IDX 1
#define Z_IDX 2



@interface NFViewVolume()
@property (nonatomic, assign) GLKMatrix4 projection;
- (void) recalculateProjection;
@end


@implementation NFViewVolume

@synthesize projection = _projection;

@synthesize hFOV = _hFOV;
@synthesize vFOV = _vFOV;
@synthesize aspectRatio = _aspectRatio;

@synthesize nearPlaneDistance = _nearPlaneDistance;
@synthesize farPlaneDistance = _farPlaneDistance;


// hFOV = 2 * arctan(tan(vFOV/2) * aspectRatio)
// vFOV = 2 * arctan(tan(hFOV/2) * 1/aspectRatio)

// aspectRatio = hFOV / (2 * arctan(tan(vFOV/2)))

//
// TODO: override all these setters to update the project matrix
//
//@property (nonatomic, assign) float hFOV;
//@property (nonatomic, assign) float vFOV;


- (void) setNearPlaneDistance:(float)nearPlaneDistance {
    _nearPlaneDistance = nearPlaneDistance;
    [self recalculateProjection];
}

- (void) setFarPlaneDistance:(float)farPlaneDistance {
    _farPlaneDistance = farPlaneDistance;
    [self recalculateProjection];
}

- (void) setAspectRatio:(float)aspectRatio {
    _aspectRatio = aspectRatio;
    [self recalculateProjection];
}

- (void) recalculateProjection {
    self.projection = GLKMatrix4MakePerspective(self.vFOV, self.aspectRatio, self.nearPlaneDistance, self.farPlaneDistance);
}

- (void) setShapeWithVerticalFOV:(float)vAngle withAspectRatio:(float)aspect
                    withNearDist:(float)nearDist withFarDist:(float)farDist {
    //
    // TODO: verify that this will correctly set the properties but only calculate the
    //       projection matrix once
    //
    _vFOV = vAngle;
    _aspectRatio = aspect;
    _nearPlaneDistance = nearDist;
    _farPlaneDistance = farDist;
    [self recalculateProjection];
}

@end



@interface NFCamera()

@property (nonatomic, assign) GLKMatrix4 viewMatrix;

@property (nonatomic, assign) GLKVector3 eye;
@property (nonatomic, assign) GLKVector3 look;
@property (nonatomic, assign) GLKVector3 right;
@property (nonatomic, assign) GLKVector3 up;

@property (nonatomic, assign) float yaw;
@property (nonatomic, assign) float pitch;

//
// TODO: store original vectors and yaw/pitch angles
//

@property (nonatomic, assign) NSUInteger currentFlags;

//
// TODO: need to setup to allow external control over the translation speed
//
// component values is what will be applied as a translation based on the camera state
@property (nonatomic, assign) GLKVector4 translationSpeed;

- (void) setEyePosition:(GLKVector3)eye withLookVector:(GLKVector3)look withUpVector:(GLKVector3)up;

@end


@implementation NFCamera

@synthesize viewMatrix = _viewMatrix;

@synthesize eye = _eye;
@synthesize look = _look;
@synthesize up = _up;

@synthesize yaw = _yaw;
@synthesize pitch = _pitch;

@synthesize currentFlags = _currentFlags;
@synthesize translationSpeed = _translationSpeed;

- (GLKMatrix4) getViewMatrix {
    return _viewMatrix;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {

        //
        // TODO: read default values from an engine config file
        //
        _eye = GLKVector3Make(4.0f, 2.0f, 4.0f);
        _look = GLKVector3Make(0.0f, 0.0f, 0.0f);
        _up = GLKVector3Make(0.0f, 1.0f, 0.0f);

        //
        // TODO: calculate actual value rather than hardcoding
        //
        _yaw = -M_PI + M_PI_4;
        _pitch = -M_PI_4 / 2.0f;

        [self setCurrentFlags:0x00];
        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];

        [self setLookWithYaw:_yaw withPitch:_pitch];
    }

    return self;
}

- (instancetype) initWithEyePosition:(GLKVector3)eye withLookVector:(GLKVector3)look withUpVector:(GLKVector3)up {
    self = [super init];
    if (self != nil) {

        _eye = eye;
        _look = look;
        _up = up;


        //
        // TODO: need to calculate the starting angles based on the eye, look, and up vectors
        //       should also extract horizontal and vertical angle from camera class since they
        //       can be changed with setViewParams method (or remove the setViewParams method and
        //       replace with translate and lookAt methods - would still need to determine
        //       horizontal and vertical angles from both methods)
        //

        // horizontal angle should just be the angle between the x,z points
        // vertical angle should just be the angle between the y,z points

        //m_horizontalAngle = M_PI;    // look to -Z
        //m_horizontalAngle = -M_PI;   // look to -Z
        //m_horizontalAngle = 0.0f;    // look to +Z

        //m_verticalAngle = M_PI_2 - 0.01f;   // look straight up
        //m_verticalAngle = -M_PI_2 + 0.01f;  // look straight down
        //m_verticalAngle = 0.0f;             // look at horizon

        _yaw = -M_PI + M_PI_4;
        _pitch = -M_PI_4 / 2.0f;


        [self setCurrentFlags:0x00];
        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];

        [self setLookWithYaw:_yaw withPitch:_pitch];
    }
    
    return self;
}

- (void) setLookWithYaw:(float)yawAngle withPitch:(float)pitchAngle {
    self.yaw = yawAngle;
    self.pitch = pitchAngle;

    GLKVector3 look;
    float r = cosf(pitchAngle);
    look.v[0] = r * sinf(yawAngle);
    look.v[1] = sinf(pitchAngle);
    look.v[2] = r * cosf(yawAngle);

    GLKVector3 right;
    right.v[0] = sinf(yawAngle - M_PI_2);
    right.v[1] = 0.0f;
    right.v[2] = cosf(yawAngle - M_PI_2);

    self.right = right;

    GLKVector3 up = GLKVector3CrossProduct(right, look);

    [self setEyePosition:self.eye withLookVector:GLKVector3Add(self.eye, look) withUpVector:up];
}

//
// TODO: currently move camera along absolute axis, modify so that translation occurs
//       along the look vector
//
- (void) step:(float)secsElapsed {

    //
    // TODO: increment position by multiple of time delta
    //

    BOOL updated = NO;
    GLKVector3 position = self.eye;

    if (self.currentFlags & FORWARD_BIT) {
        GLKVector3 translationVec = GLKVector3Normalize(GLKVector3Subtract(position, self.look));
        translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.v[Z_IDX]);
        position = GLKVector3Subtract(position, translationVec);
        updated = YES;
    }

    if (self.currentFlags & BACK_BIT) {
        GLKVector3 translationVec = GLKVector3Normalize(GLKVector3Subtract(position, self.look));
        translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.v[Z_IDX]);
        position = GLKVector3Add(position, translationVec);
        updated = YES;
    }


    //
    // TODO: forward/backward works correctly, left/right does not
    //
    if (self.currentFlags & LEFT_BIT) {

        //
        // TODO: translationVec needs to be calculated with the right vector ??
        //

        //GLKVector3 translationVec = GLKVector3Normalize(GLKVector3Add(position, self.right));

        //translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.v[X_IDX]);
        //position = GLKVector3Subtract(position, translationVec);

        updated = YES;
    }

    if (self.currentFlags & RIGHT_BIT) {

        //GLKVector3 translationVec = GLKVector3Normalize(GLKVector3Add(position, self.right));

        //translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.v[X_IDX]);
        //position = GLKVector3Add(position, translationVec);

        updated = YES;
    }


    if (updated) {
        self.eye = position;
        [self setLookWithYaw:self.yaw withPitch:self.pitch];
    }
}

- (void) setTranslationState:(CAMERA_STATE)state {

#if 0
    if (state == kCameraStateActFwd && self.currentFlags & FORWARD_BIT) {
        return;
    }
    else if (state == kCameraStateActBack && self.currentFlags & BACK_BIT) {
        return;
    }
#endif

    switch (state) {

            // set direction bit and update position

        case kCameraStateActFwd:
            self.currentFlags = self.currentFlags | FORWARD_BIT;
            break;

        case kCameraStateActBack:
            self.currentFlags = self.currentFlags | BACK_BIT;
            break;

        case kCameraStateActLeft:
            self.currentFlags = self.currentFlags | LEFT_BIT;
            break;

        case kCameraStateActRight:
            self.currentFlags = self.currentFlags | RIGHT_BIT;
            break;

            // unset direction bit

        case kCameraStateNilFwd:
            self.currentFlags = self.currentFlags & ~FORWARD_BIT;
            break;

        case kCameraStateNilBack:
            self.currentFlags = self.currentFlags & ~BACK_BIT;
            break;

        case kCameraStateNilLeft:
            self.currentFlags = self.currentFlags & ~LEFT_BIT;
            break;

        case kCameraStateNilRight:
            self.currentFlags = self.currentFlags & ~RIGHT_BIT;
            break;
    }
}

- (void) resetLookDirection {
    //
    // TODO: implement
    //
}

- (void) resetState {
    //
    // TODO: implement
    //
}

- (void) saveState {
    //
    // TODO: function will preserve the cameras current state, this state will be
    //       what is used on the next resetLookDirection and resetState calls
    //
}

- (void) setEyePosition:(GLKVector3)eye withLookVector:(GLKVector3)look withUpVector:(GLKVector3)up {
    self.eye = eye;
    self.look = look;
    self.up = up;

    // NOTE: it would appear that GLK is using a UVN based coordinate system under-the-hood
    _viewMatrix = GLKMatrix4MakeLookAt(eye.v[0], eye.v[1], eye.v[2],
                                       look.v[0], look.v[1], look.v[2],
                                       up.v[0], up.v[1], up.v[2]);
}

@end
