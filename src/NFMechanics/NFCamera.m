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

@interface NFCamera()

@property (nonatomic, assign) GLKVector4 motionVector;
@property (nonatomic, assign) GLKVector4 position;

@property (nonatomic, assign) NSUInteger currentState;

@end


@implementation NFCamera

@synthesize motionVector = _motionVector;
@synthesize position = _position;

@synthesize currentState = _currentState;

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        [self setMotionVector:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];
        [self setPosition:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];
        [self setCurrentState:0x00];
    }
    return self;
}

- (void) step {
    //
    // TODO: update camera position based on motion vector
    //
}

- (void) setState:(CAMERA_STATE) state {
    // check if current state is set and exit if it is
    if (self.currentState & state) {
        return;
    }

    switch (state) {

        // set direction bit

        case kCameraStateActFwd:

            self.currentState = self.currentState | FORWARD_BIT;
            // z 0.1

            break;

        case kCameraStateActBack:

            self.currentState = self.currentState | BACK_BIT;
            // z -0.1

            break;

        case kCameraStateActLeft:
            self.currentState = self.currentState | LEFT_BIT;
            break;

        case kCameraStateActRight:
            self.currentState = self.currentState | RIGHT_BIT;
            break;

        // unset direction bit

        case kCameraStateNilFwd:
            NSLog(@"update camera state to NIL forward");
            self.currentState = self.currentState & ~FORWARD_BIT;
            break;

        case kCameraStateNilBack:
            NSLog(@"update camera state to NIL backwards");
            self.currentState = self.currentState & ~BACK_BIT;
            break;

        case kCameraStateNilLeft:
            self.currentState = self.currentState & ~LEFT_BIT;
            break;

        case kCameraStateNilRight:
            self.currentState = self.currentState & ~RIGHT_BIT;
            break;
    }
}

@end
