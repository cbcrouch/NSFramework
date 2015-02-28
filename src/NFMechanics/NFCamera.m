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
@property (nonatomic, assign) GLKVector3 up;

@property (nonatomic, assign) float yaw;
@property (nonatomic, assign) float pitch;



@property (nonatomic, assign) GLKVector3 cached_eye;
@property (nonatomic, assign) float cached_yaw;
@property (nonatomic, assign) float cached_pitch;



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

@synthesize cached_eye = _cached_eye;
@synthesize cached_yaw = _cached_yaw;
@synthesize cached_pitch = _cached_pitch;

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

        GLKVector3 hyp = GLKVector3Subtract(_eye, _look);
        hyp = GLKVector3Normalize(hyp);

        //_yaw = M_PI;    // look to -Z
        //_yaw = -M_PI;   // look to -Z
        //_yaw = 0.0f;    // look to +Z

        //_pitch = M_PI_2 - 0.01f;   // look straight up
        //_pitch = -M_PI_2 + 0.01f;  // look straight down
        //_pitch = 0.0f;             // look at horizon

        //
        // TODO: verify that these offsets/modifiers are what should be used
        //
        _yaw = -M_PI + atan2f(hyp.x, hyp.z);
        _pitch = -atan2(hyp.y, hyp.y) / 2.0f;

        _cached_eye = _eye;
        _cached_yaw = _yaw;
        _cached_pitch = _pitch;

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

        GLKVector3 hyp = GLKVector3Subtract(_eye, _look);
        hyp = GLKVector3Normalize(hyp);

        //
        // TODO: verify that these offsets/modifiers are what should be used
        //
        _yaw = -M_PI + atan2f(hyp.x, hyp.z);
        _pitch = -atan2(hyp.y, hyp.y) / 2.0f;

        _cached_eye = _eye;
        _cached_yaw = _yaw;
        _cached_pitch = _pitch;

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
    look.x = r * sinf(yawAngle);
    look.y = sinf(pitchAngle);
    look.z = r * cosf(yawAngle);

    GLKVector3 right;
    right.x = sinf(yawAngle - M_PI_2);
    right.y = 0.0f;
    right.z = cosf(yawAngle - M_PI_2);

    GLKVector3 up = GLKVector3CrossProduct(right, look);


    //
    // TODO: could try an alternate (potentially faster) implementation using a fixed up
    //       vector and rotating the flat yaw vector around cross(look, up) i.e.
    //
    // up = (0, 1, 0)
    // look = (cos(yaw), 0, sin(yaw))
    // pitchMatrix = rotate(matrix, cross(look, up), pitch)
    // look = pitchMatrix * look;


    [self setEyePosition:self.eye withLookVector:GLKVector3Add(self.eye, look) withUpVector:up];
}

- (void) step:(float)secsElapsed {

    //
    // TODO: translation speed should be in world units per second and scaled to the
    //       seconds elapse parameter
    //

    BOOL updated = NO;
    GLKVector3 position = self.eye;

    if (self.currentFlags & FORWARD_BIT) {
        GLKVector3 translationVec = GLKVector3Normalize(GLKVector3Subtract(position, self.look));
        translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.z);
        position = GLKVector3Subtract(position, translationVec);
        updated = YES;
    }

    if (self.currentFlags & BACK_BIT) {
        GLKVector3 translationVec = GLKVector3Normalize(GLKVector3Subtract(position, self.look));
        translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.z);
        position = GLKVector3Add(position, translationVec);
        updated = YES;
    }

    if (self.currentFlags & LEFT_BIT) {
        GLKVector3 side = GLKVector3CrossProduct(GLKVector3Subtract(position, self.look), self.up);
        GLKVector3 translationVec = GLKVector3Normalize(side);
        translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.x);
        position = GLKVector3Add(position, translationVec);
        updated = YES;
    }

    if (self.currentFlags & RIGHT_BIT) {
        GLKVector3 side = GLKVector3CrossProduct(GLKVector3Subtract(position, self.look), self.up);
        GLKVector3 translationVec = GLKVector3Normalize(side);
        translationVec = GLKVector3MultiplyScalar(translationVec, self.translationSpeed.x);
        position = GLKVector3Subtract(position, translationVec);
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
    [self setLookWithYaw:self.cached_yaw withPitch:self.cached_pitch];
}

- (void) resetState {
    self.eye = self.cached_eye;
    [self setLookWithYaw:self.cached_yaw withPitch:self.cached_pitch];
}

- (void) saveState {
    self.cached_eye = self.eye;
    self.cached_yaw = self.yaw;
    self.cached_pitch = self.pitch;
}

- (void) setEyePosition:(GLKVector3)eye withLookVector:(GLKVector3)look withUpVector:(GLKVector3)up {
    self.eye = eye;
    self.look = look;
    self.up = up;

    // NOTE: it would appear that GLK is using a UVN based coordinate system under-the-hood
    _viewMatrix = GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z,
                                       look.x, look.y, look.z,
                                       up.x, up.y, up.z);
}

@end
