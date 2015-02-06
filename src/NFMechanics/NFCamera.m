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
@property (nonatomic, assign) GLKVector3 up;

@end


@implementation NFCamera

@synthesize viewMatrix = _viewMatrix;

@synthesize eye = _eye;
@synthesize look = _look;
@synthesize up = _up;

- (GLKMatrix4) getViewMatrix {
    return _viewMatrix;
}

- (void) setLookHorizontalAngle:(float)h_angle verticalAngle:(float)v_angle {

    // h_angle == yaw
    // v_angle == pitch

    GLKVector3 look;
    float r = cosf(v_angle);
    look.v[0] = r * sinf(h_angle);
    look.v[1] = sinf(v_angle);
    look.v[2] = r * cosf(h_angle);

    GLKVector3 right;
    right.v[0] = sinf(h_angle - M_PI_2);
    right.v[1] = 0.0f;
    right.v[2] = cosf(h_angle - M_PI_2);

    GLKVector3 up = GLKVector3CrossProduct(right, look);

    [self setEyePosition:self.eye withLookVector:GLKVector3Add(self.eye, look) withUpVector:up];
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

- (void) step:(NSUInteger)milliseconds {
    //
    //
    //
}

- (void) setTranslationState:(CAMERA_STATE)state {
    //
    //
    //
}

- (void) resetTarget {
    //
    //
    //
}

- (void) resetPosition {
    //
    //
    //
}

@end


/*
@interface NFCamera()

@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 target;
@property (nonatomic, assign) GLKVector3 up;

@property (nonatomic, assign) GLKVector3 initialPosition;
@property (nonatomic, assign) GLKVector3 initialTarget;
@property (nonatomic, assign) GLKVector3 initialUp;

@property (nonatomic, assign) GLKVector3 U;
@property (nonatomic, assign) GLKVector3 V;
@property (nonatomic, assign) GLKVector3 N;

@property (nonatomic, retain) NFViewVolume* viewVolume;

@property (nonatomic, assign) NSUInteger currentFlags;

@property (nonatomic, assign) GLKMatrix4 viewMatrix;

- (void) updateModelViewMatrix;

@end


@implementation NFCamera

//@synthesize hFOV = _hFOV;
@synthesize vFOV = _vFOV;

@synthesize position = _position;
@synthesize target = _target;
@synthesize up = _up;

@synthesize nearPlaneDistance = _nearPlaneDistance;
@synthesize farPlaneDistance = _farPlaneDistance;
@synthesize aspectRatio = _aspectRatio;


@synthesize initialTarget = _initialTarget;
@synthesize initialPosition = _initialPosition;
@synthesize initialUp = _initialUp;

@synthesize U = _U;
@synthesize V = _V;
@synthesize N = _N;


@synthesize viewVolume = _viewVolume;

@synthesize translationSpeed = _translationSpeed;

@synthesize currentFlags = _currentFlags;


@synthesize viewMatrix = _viewMatrix;


- (GLKVector3) position {
    return _position;
}

- (GLKVector3) target {
    return _target;
}

- (GLKVector3) up {
    return _up;
}

- (void) setUp:(GLKVector3)up {
    _up = GLKVector3Normalize(up);
}

- (void) setNearPlaneDistance:(float)nearPlaneDistance {
    _nearPlaneDistance = nearPlaneDistance;
    self.viewVolume.projection = GLKMatrix4MakePerspective(self.vFOV, self.aspectRatio,
                                                           nearPlaneDistance, self.farPlaneDistance);
}

- (void) setFarPlaneDistance:(float)farPlaneDistance {
    _farPlaneDistance = farPlaneDistance;
    self.viewVolume.projection = GLKMatrix4MakePerspective(self.vFOV, self.aspectRatio,
                                                           self.nearPlaneDistance, farPlaneDistance);
}

- (void) setAspectRatio:(float)aspectRatio {
    _aspectRatio = aspectRatio;
    self.viewVolume.projection = GLKMatrix4MakePerspective(self.vFOV, aspectRatio,
                                                           self.nearPlaneDistance, self.farPlaneDistance);
}

- (GLKMatrix4) getViewMatrix {
    return self.viewMatrix;
}
- (GLKMatrix4) getProjectionMatrix {
    return self.viewVolume.projection;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: allow default values to be configured or set them to same defaults
        //       as either Maya, Blender, 3DS Max, Unreal, etc. based on whichever
        //       makes the most sense (try Maya first, would be a nice nod towards
        //       Alias Wavefront which also where the obj file format comes from)
        //
        GLKVector3 position = GLKVector3Make(4.0f, 2.0f, 4.0f);
        GLKVector3 target = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 up = GLKVector3Make(0.0f, 1.0f, 0.0f);

        // set initial vectors so that the camera can be reset if the user becomes lost
        [self setInitialPosition:[self position]];
        [self setInitialTarget:[self target]];
        [self setInitialUp:[self up]];

        NFViewVolume *viewVolume = [[[NFViewVolume alloc] init] autorelease];
        
        //
        // TODO: need better defined defaults for projection matrix
        //
        CGFloat nearPlane = 1.0f;
        CGFloat farPlane = 100.0f;
        CGFloat width = 1280.0f;
        CGFloat height = 720.0f;
        CGFloat fov = (CGFloat)M_PI_4;

        [self setNearPlaneDistance:nearPlane];
        [self setFarPlaneDistance:farPlane];
        [self setVFOV:fov];
        [self setAspectRatio:width / height];

        viewVolume.projection = GLKMatrix4MakePerspective(fov, width / height, nearPlane, farPlane);

        [self setViewVolume:viewVolume];
        [self setPosition:position withTarget:target withUp:up];
        [self setCurrentFlags:0x00];

        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];
    }
    return self;
}

- (instancetype) initWithPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up {
    self = [super init];
    if (self != nil) {
        [self setPosition:position];
        [self setTarget:target];
        [self setUp:up];

        // set initial vectors so that the camera can be reset if the user becomes lost
        [self setInitialPosition:position];
        [self setInitialTarget:target];
        [self setInitialUp:up];

        [self setCurrentFlags:0x00];

        //[self setMotionVector:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];

        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];
    }
    return self;
}

// NOTE: delta is measured in microseconds
- (void) step:(NSUInteger)delta {
    //
    // TODO: update camera position based on motion vector
    //

    //
    // TODO: increment position by multiple of time delta
    //

    if (self.currentFlags & FORWARD_BIT) {
        [self translateWithDeltaX:0.0f withDeltaY:0.0f withDeltaZ:-self.translationSpeed.v[Z_IDX]];
    }

    if (self.currentFlags & BACK_BIT) {
        [self translateWithDeltaX:0.0f withDeltaY:0.0f withDeltaZ:self.translationSpeed.v[Z_IDX]];
    }

    if (self.currentFlags & LEFT_BIT) {
        [self translateWithDeltaX:self.translationSpeed.v[X_IDX] withDeltaY:0.0f withDeltaZ:0.0f];
    }

    if (self.currentFlags & RIGHT_BIT) {
        [self translateWithDeltaX:-self.translationSpeed.v[X_IDX] withDeltaY:0.0f withDeltaZ:0.0f];
    }
}

- (void) setState:(CAMERA_STATE)state {

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

- (void) resetTarget {
    self.target = self.initialTarget;
}

- (void) resetPosition {
    self.up = self.initialUp;
    self.position = self.initialPosition;
}

- (void) setPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up {
    self.position = position;
    self.target = target;
    self.up = up;

    self.N = GLKVector3Subtract(position, target);
    self.U = GLKVector3CrossProduct(up, self.N);

    self.N = GLKVector3Normalize(self.N);
    self.U = GLKVector3Normalize(self.U);

    self.V = GLKVector3CrossProduct(self.N, self.U);

    [self updateModelViewMatrix];
}

- (void) setShapeWithVerticalFOV:(float)vAngle withAspectRatio:(float)aspect
                    withNearDist:(float)nearDist withFarDist:(float)farDist {
    //
    // TODO: somewhat costly to be recalculating the projection matrix on every setter
    //       (should clean it up so it is only calculated once)
    //
    self.vFOV = vAngle;
    self.aspectRatio = aspect;
    self.nearPlaneDistance = nearDist;
    self.farPlaneDistance = farDist;
}

- (void) translateWithVector3:(GLKVector3)vec {
    self.position.v[0] += vec.v[0] * self.U.v[0] + vec.v[0] * self.V.v[0] + vec.v[0] * self.N.v[0];
    self.position.v[1] += vec.v[1] * self.U.v[1] + vec.v[1] * self.V.v[1] + vec.v[1] * self.N.v[1];
    self.position.v[2] += vec.v[2] * self.U.v[2] + vec.v[2] * self.V.v[2] + vec.v[2] * self.N.v[2];

    [self updateModelViewMatrix];
}

- (void) translateWithDeltaX:(float)delX withDeltaY:(float)delY withDeltaZ:(float)delZ {
    //
    // NOTE: cannot assign directly to property struct members since getter will
    //       return the current value, need to capture as a temp, modify, and then
    //       reassign the changed value(s)
    //
    GLKVector3 temp = self.position;

    temp.v[0] += delX * self.U.v[0] + delY * self.V.v[0] + delZ * self.N.v[0];
    temp.v[1] += delX * self.U.v[1] + delY * self.V.v[1] + delZ * self.N.v[1];
    temp.v[2] += delX * self.U.v[2] + delY * self.V.v[2] + delZ * self.N.v[2];

    self.position = temp;

    [self updateModelViewMatrix];
}

- (void) roll:(float)angle {
    float cs = cosf(angle);
    float sn = sinf(angle);

    GLKVector3 tempU = self.U;
    GLKVector3 tempV = self.V;

    GLKVector3 t = self.U;

    //
    // TODO: use X_IDX, Y_IDX, Z_IDX
    //

    tempU.v[0] = cs * t.v[0] - sn * self.V.v[0];
    tempU.v[1] = cs * t.v[1] - sn * self.V.v[1];
    tempU.v[2] = cs * t.v[2] - sn * self.V.v[2];

    tempV.v[0] = sn * t.v[0] + cs * self.V.v[0];
    tempV.v[1] = sn * t.v[1] + cs * self.V.v[1];
    tempV.v[2] = sn * t.v[2] + cs * self.V.v[2];

    self.U = tempU;
    self.V = tempV;

    [self updateModelViewMatrix];
}

- (void) pitch:(float)angle {
    float cs = cosf(angle);
    float sn = sinf(angle);

    GLKVector3 tempN = self.N;
    GLKVector3 tempV = self.V;

    GLKVector3 t = self.N;

    tempN.v[0] = cs * t.v[0] - sn * self.V.v[0];
    tempN.v[1] = cs * t.v[1] - sn * self.V.v[1];
    tempN.v[2] = cs * t.v[2] - sn * self.V.v[2];

    tempV.v[0] = sn * t.v[0] + cs * self.V.v[0];
    tempV.v[1] = sn * t.v[1] + cs * self.V.v[1];
    tempV.v[2] = sn * t.v[2] + cs * self.V.v[2];

    self.N = tempN;
    self.V = tempV;

    [self updateModelViewMatrix];
}

- (void) yaw:(float)angle {
    float cs = cosf(angle);
    float sn = sinf(angle);

    GLKVector3 tempU = self.U;
    GLKVector3 tempN = self.N;

    GLKVector3 t = self.U;

    tempU.v[0] = cs * t.v[0] - sn * self.N.v[0];
    tempU.v[1] = cs * t.v[1] - sn * self.N.v[1];
    tempU.v[2] = cs * t.v[2] - sn * self.N.v[2];

    tempN.v[0] = sn * t.v[0] + cs * self.N.v[0];
    tempN.v[1] = sn * t.v[1] + cs * self.N.v[1];
    tempN.v[2] = sn * t.v[2] + cs * self.N.v[2];

    self.U = tempU;
    self.N = tempN;

    [self updateModelViewMatrix];
}

- (void) updateModelViewMatrix {
    GLKMatrix4 viewMat;

    viewMat.m[0] = self.U.v[0];
    viewMat.m[1] = self.V.v[0];
    viewMat.m[2] = self.N.v[0];
    viewMat.m[3] = 0.0f;

    viewMat.m[4] = self.U.v[1];
    viewMat.m[5] = self.V.v[1];
    viewMat.m[6] = self.N.v[1];
    viewMat.m[7] = 0.0f;

    viewMat.m[8]  = self.U.v[2];
    viewMat.m[9]  = self.V.v[2];
    viewMat.m[10] = self.N.v[2];
    viewMat.m[11] = 0.0f;

    viewMat.m[12] = -1.0f * GLKVector3DotProduct(self.position, self.U);
    viewMat.m[13] = -1.0f * GLKVector3DotProduct(self.position, self.V);
    viewMat.m[14] = -1.0f * GLKVector3DotProduct(self.position, self.N);
    viewMat.m[15] = 1.0f;

    self.viewMatrix = viewMat;
}

@end
*/
