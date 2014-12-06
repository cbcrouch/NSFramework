//
//  NFCamera.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFCamera.h"

#define FORWARD_BIT 0x01
#define BACK_BIT    0x02
#define LEFT_BIT    0x04
#define RIGHT_BIT   0x08


#define X_POS 0
#define Y_POS 1
#define Z_POS 2


@implementation NFMotionVector

@synthesize currentValue = _currentValue;
@synthesize modifier = _modifier;
@synthesize updateRate = _updateRate;

@end


@interface NFCamera()

//
// TODO: make a stack of motionVectors
//
//@property (nonatomic, assign) NFMotionVector motionVector;

@property (nonatomic, assign) NSUInteger currentFlags;

@property (nonatomic, assign) float aspectRatio;

@end


@implementation NFCamera

//@synthesize motionVector = _motionVector;


//
// TODO: override setters so that any observers are notified of a change
//
@synthesize position = _position;
@synthesize target = _target;
@synthesize up = _up;

@synthesize translationSpeed = _translationSpeed;

//@synthesize hFOV = _hFOV;
@synthesize vFOV = _vFOV;
@synthesize width = _width;
@synthesize height = _height;
@synthesize aspectRatio = _aspectRatio;

@synthesize currentFlags = _currentFlags;

@synthesize observer = _observer;

- (void) setPosition:(GLKVector4)position {
    _position = position;
    if (self.observer != nil) {
        [self.observer notifyOfStateChange];
    }
}

- (void) setTarget:(GLKVector4)target {
    _target = target;
    if (self.observer != nil) {
        [self.observer notifyOfStateChange];
    }
}

- (void) setUp:(GLKVector4)up {
    _up = up;
    if (self.observer != nil) {
        [self.observer notifyOfStateChange];
    }
}

- (void) setWidth:(NSUInteger)width {
    _width = width;
    self.aspectRatio = width / (float) self.height;
}

- (void) setHeight:(NSUInteger)height {
    _height = height;
    self.aspectRatio = self.width / (float) height;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: allow default values to be configured
        //
        [self setPosition:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];
        [self setTarget:GLKVector4Make(1.0f, 0.0f, 1.0f, 0.0f)];
        [self setUp:GLKVector4Make(0.0f, 1.0f, 0.0f, 0.0f)];

        [self setCurrentFlags:0x00];

        //[self setMotionVector:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];

        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];
    }
    return self;
}

- (void) step:(NSUInteger)delta {
    //
    // TODO: update camera position based on motion vector
    //

    BOOL positionChanged = NO;
    GLKVector4 newPosition = self.position;
    GLKVector4 newTarget = self.target;

    // NOTE: delta is measured in microseconds

    //
    // TODO: increment position by multiple of time delta
    //

    if (self.currentFlags & FORWARD_BIT) {
        newPosition.v[Z_POS] += self.translationSpeed.v[Z_POS];
        newTarget.v[Z_POS] += self.translationSpeed.v[Z_POS];
        positionChanged = YES;
    }

    //
    // TODO: could possibly use GLKMatrix4TranslateWithVector4
    //

    if (self.currentFlags & BACK_BIT) {
        newPosition.v[Z_POS] -= self.translationSpeed.v[Z_POS];
        newTarget.v[Z_POS] -= self.translationSpeed.v[Z_POS];
        positionChanged = YES;
    }

    if (self.currentFlags & LEFT_BIT) {
        newPosition.v[X_POS] -= self.translationSpeed.v[X_POS];
        newTarget.v[X_POS] -= self.translationSpeed.v[X_POS];
        positionChanged = YES;
    }

    if (self.currentFlags & RIGHT_BIT) {
        newPosition.v[X_POS] += self.translationSpeed.v[X_POS];
        newTarget.v[X_POS] += self.translationSpeed.v[X_POS];
        positionChanged = YES;
    }

    if (positionChanged) {
        self.position = newPosition;
        self.target = newTarget;
    }
}

- (void) pushMotionVector:(NFMotionVector *)motionVector {
    //
}

- (void) clearMotionVectors {
    //
}

- (void) setState:(CAMERA_STATE)state {

    //
    // TODO: this should be checking against the bit flags
    //       not the enum state
    //

    if (state == kCameraStateActFwd && self.currentFlags & FORWARD_BIT) {
        return;
    }
    else if (state == kCameraStateActBack && self.currentFlags & BACK_BIT) {
        return;
    }

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

- (void) addObserver:(id)obj {
    self.observer = obj;
}

@end
