//
//  NFCamera.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

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


//
// TODO: these should be stored here, they are part of the viewport/framebuffer which
//       belong in the renderer
//
// width and height of the camera (i.e. the camera's target resolution)
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;


@property (nonatomic, assign, readonly) float aspectRatio;


//
// TODO: extract these values from either the UVN coordinates or the modelview matrix
//       (benchmark to determine fastest method)
//
@property (nonatomic, assign, readonly) GLKVector3 position;
@property (nonatomic, assign, readonly) GLKVector3 target;
@property (nonatomic, assign, readonly) GLKVector3 up;



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


//
// TODO: is vertical FOV and aspect ratio enough to determine width/height
//
/*
- (void) setShapeWithVerticalFOV:(float)vAngle withAspectRatio:(float)aspect
                    withNearDist:(float)nearDist withFarDist:(float)farDist;
*/

//- (void) setNearClipDistance:(float)nearDist;
//- (void) setFarClipDistance:(float)farDist;



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

// http://stackoverflow.com/questions/25933581/how-u-v-n-camera-coordinate-system-explained-with-opengl
// https://www.siggraph.org/education/materials/HyperGraph/viewing/view3d/3dview1.htm
// http://ogldev.atspace.co.uk/www/tutorial13/tutorial13.html

- (GLKMatrix4) getViewMatrix;
- (GLKMatrix4) getProjectionMatrix;


@end
