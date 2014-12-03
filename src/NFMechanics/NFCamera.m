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

@property (nonatomic, assign) NSUInteger currentState;

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

@synthesize currentState = _currentState;

@synthesize observer = _observer;

- (void) setPosition:(GLKVector4)position {
    _position = position;

    NSLog(@"setPosition: (%f, %f, %f)", _position.v[0], _position.v[1], _position.v[2]);

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

        [self setCurrentState:0x00];

        //[self setMotionVector:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];

        [self setTranslationSpeed:GLKVector4Make(0.1f, 0.0f, 0.1f, 0.0f)];
    }
    return self;
}

- (void) step {
    //
    // TODO: update camera position based on motion vector
    //
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

    if (state == kCameraStateActFwd && self.currentState & FORWARD_BIT) {
        return;
    }
    else if (state == kCameraStateActBack && self.currentState & BACK_BIT) {
        return;
    }



    BOOL positionChanged = NO;
    GLKVector4 newPosition = self.position;
    switch (state) {

        // set direction bit and update position

        case kCameraStateActFwd:
            self.currentState = self.currentState | FORWARD_BIT;


            //
            // TODO: update the position in the step method
            //
            newPosition.v[Z_POS] += self.translationSpeed.v[Z_POS];
            positionChanged = YES;


            break;

        case kCameraStateActBack:
            self.currentState = self.currentState | BACK_BIT;
            newPosition.v[Z_POS] -= self.translationSpeed.v[Z_POS];
            positionChanged = YES;
            break;

        case kCameraStateActLeft:
            self.currentState = self.currentState | LEFT_BIT;
            newPosition.v[X_POS] -= self.translationSpeed.v[X_POS];
            positionChanged = YES;
            break;

        case kCameraStateActRight:
            self.currentState = self.currentState | RIGHT_BIT;
            newPosition.v[X_POS] += self.translationSpeed.v[X_POS];
            positionChanged = YES;
            break;

        // unset direction bit

        case kCameraStateNilFwd:
            self.currentState = self.currentState & ~FORWARD_BIT;
            break;

        case kCameraStateNilBack:
            self.currentState = self.currentState & ~BACK_BIT;
            break;

        case kCameraStateNilLeft:
            self.currentState = self.currentState & ~LEFT_BIT;
            break;

        case kCameraStateNilRight:
            self.currentState = self.currentState & ~RIGHT_BIT;
            break;
    }

    if (positionChanged) {
        self.position = newPosition;
    }
}

- (void) addObserver:(id)obj {
    self.observer = obj;
}

@end
