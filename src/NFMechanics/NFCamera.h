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
// TODO: move this back to the NFViewVolume.h/.m after refactoring
//
@interface NFViewVolume : NSObject
@property (nonatomic, assign) GLKMatrix4 view;
@property (nonatomic, assign) GLKMatrix4 projection;

@property (nonatomic, assign) CGFloat farPlane;
@property (nonatomic, assign) CGFloat nearPlane;

@property (nonatomic, assign) CGSize viewportSize;
@end




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


- (GLKMatrix4) getViewMatrix;
- (GLKMatrix4) getProjectionMatrix;


//
// TODO: methods for setting view volume projection properties
//

//
// TODO: these are temporary setters
//
- (void) setViewMatrix:(GLKMatrix4)view;
- (void) setProjectionMatrix:(GLKMatrix4)projection;

//
// TODO: add override view/projection matrices and an apply matrix to view method
//


// for NFDataSourceProtocol
- (void) addObserver:(id)obj;



@end
