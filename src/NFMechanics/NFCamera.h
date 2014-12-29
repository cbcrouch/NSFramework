//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFViewVolume.h"
#import "NFUtils.h"


//
// TODO: rename enum NF_CAMERA_TRANSLATION_STATE or something similar
//
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


@interface NFCamera : NSObject

//
// TODO: allow user control to set the horizontal FOV which will modify the aspect ratio or camera resolution ??
//
//@property (nonatomic, assign) float hFOV;

@property (nonatomic, assign) float vFOV; // fov Y in radians

// width and height of the camera (i.e. the camera's target resolution)
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, readonly, assign) float aspectRatio;



//
// TODO: make these read only properties (they will be updated through
//       setting the translation state or using the roll/pitch/yaw methods)
//
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 target;
@property (nonatomic, assign) GLKVector3 up;



// component values is what will be applied as a translation based on the camera state
@property (nonatomic, assign) GLKVector4 translationSpeed;


- (instancetype) initWithPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up;


//
// TODO: pass in microsecond step
//
- (void) step:(NSUInteger)delta;

- (void) pushMotionVector:(NFMotionVector *)motionVector;
- (void) clearMotionVectors;


//
// TODO: should rename this to something like setTranslationState
//
- (void) setState:(CAMERA_STATE)state;


- (void) resetTarget;
- (void) resetPosition; // TODO: needs a better name resetToInitialValues ??


- (void) setPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up;

// NOTE: translations are relative movements to the camera's current position
- (void) translateWithVector3:(GLKVector3)vec;
- (void) translateWithDeltaX:(float)delX withDeltaY:(float)delY withDeltaZ:(float)delZ;

- (void) roll:(float)angle;
- (void) pitch:(float)angle;
- (void) yaw:(float)angle;

//
// TODO: while the sparse documentation online does claim that the UVN camera system will
//       prevent gimbal lock, should really prove it mathematically
//

// UVN camera coordinate system is left handed

// use VUN for right handed coordinate sysetm

// http://stackoverflow.com/questions/25933581/how-u-v-n-camera-coordinate-system-explained-with-opengl
// https://www.siggraph.org/education/materials/HyperGraph/viewing/view3d/3dview1.htm
// http://ogldev.atspace.co.uk/www/tutorial13/tutorial13.html

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



@end
