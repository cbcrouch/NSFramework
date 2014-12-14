//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFUtils.h"
#import "NFProtocols.h"


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


//
// TODO: will need to convert an NFCamera into an NFViewVolume
//

// NFViewVolume and NFCamera will contain weak references to each other which are set with
// a "bind" method, will then still need to determine which one polls for the others information
// or which one becomes an observer of the other

// NFCamera should not know about the implemenation of the NFViewVolume, will only have an id
// which it knows certain changes will need to be forwarded to, how that forward mechanism works
// is still TBD at this point


@interface NFCamera : NSObject <NFDataSourceProtocol>

//
// TODO: allow user control to set the horizontal FOV which will modify the aspect ratio or camera resolution ??
//
//@property (nonatomic, assign) float hFOV;

@property (nonatomic, assign) float vFOV; // fov Y in radians

// width and height of the camera (i.e. the camera's target resolution)
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, readonly, assign) float aspectRatio;

@property (nonatomic, assign) GLKVector4 position;
@property (nonatomic, assign) GLKVector4 target;
@property (nonatomic, assign) GLKVector4 up;


// component values is what will be applied as a translation based on the camera state
@property (nonatomic, assign) GLKVector4 translationSpeed;


//
// TODO: make sure that assign doesn't increment retain count on observer, very important
//       to avoid cyclic strong references since the NFViewVolume will make a retain
//       call on NFCamera object
//
@property (nonatomic, assign) id <NFObserverProtocol> observer;

- (instancetype) initWithPosition:(GLKVector4)position withTarget:(GLKVector4)target withUp:(GLKVector4)up;

//
// TODO: pass in microsecond step
//
- (void) step:(NSUInteger)delta;

- (void) pushMotionVector:(NFMotionVector *)motionVector;
- (void) clearMotionVectors;

- (void) setState:(CAMERA_STATE)state;

- (void) resetTarget;
- (void) resetPosition;

// for NFDataSourceProtocol
- (void) addObserver:(id)obj;

@end
