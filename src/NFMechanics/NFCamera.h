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



// could use NSNotificationCenter to implement observer pattern
// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/

// or could use key-value observing
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html




@interface NFCamera : NSObject <NFDataSourceProtocol>


//
// TODO: allow user control to set the horizontal FOV which will modify the aspect ratio or camera resolution ??
//
//@property (nonatomic, assign) float hFOV;

@property (nonatomic, assign) float vFOV; // fov Y in radians

// width and height of the camera (i.e. the camera's target resolution)

// keep readonly property for aspectRatio


// to create the perspective matrix will need to provide the fovY and aspect ratio to the view volume
// while the near and far Z will be provided by the rendering subsystem

//GLK_INLINE GLKMatrix4 GLKMatrix4MakePerspective(float fovyRadians, float aspect, float nearZ, float farZ)


@property (nonatomic, readonly, assign) GLKVector4 position;

//
// TODO: make sure that assign doesn't increment retain count on observer, very important
//       to avoid cyclic strong references since the NFViewVolume will make a retain
//       call on NFCamera object
//
@property (nonatomic, assign) id <NFObserverProtocol> observer;


//
// TODO: provide a time delta which will be used as a motion vector scalar
//
- (void) step;

- (void) pushMotionVector:(NFMotionVector *)motionVector;
- (void) setState:(CAMERA_STATE)state;

// for NFDataSourceProtocol
- (void) addObserver:(id)obj;

@end
