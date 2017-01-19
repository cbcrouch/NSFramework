//
//  NFRenderer.h
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


//
// TODO: allow configuring a default viewport via external config
//
#define MAX_NUM_VIEWPORTS 8
#define DEFAULT_VIEWPORT_WIDTH 1280
#define DEFAULT_VIEWPORT_HEIGHT 720

typedef NSInteger NFViewportId;


@interface NFRenderer : NSObject


//
// TODO: this is a temporary/debug featuer to all the spacebar to pause/unpause animations
//       (should be replace when a better mechanism for controlling asset animation)
//
@property (nonatomic, assign) BOOL stepTransforms;


//
// TODO: the renderer should have viewport origin and width/height which can be
//       different than the width/height of the camera i.e. the viewport is the
//       area of screen being rendered into and the camera width/heigh is the
//       pixel resolution of the rendered image
//
//- (instancetype) initWithWidth:(NSInteger)width withHeight(NSInteger)height NS_DESIGNATED_INITIALIZER;
//- (instancetype) initWithViewport:(NSRect)viewportRect;


//
// TODO: group view/projection matrix and view position into a ViewDescription structure
//       (could probably find a better name)
//
- (void) updateFrameWithTime:(float)secsElapsed withViewPosition:(GLKVector3)viewPosition
              withViewMatrix:(GLKMatrix4)viewMatrix
              withProjection:(GLKMatrix4)projection;


- (void) renderFrame;

//
// TODO: renderer instance should have a more robust viewport interface i.e. can have
//       support for mutliple viewports in the same renderer instance
//
- (void) resizeToRect:(CGRect) rect;

//
// TODO: need to add some utility functions for adding/removing/resizing viewports
//       and determine what the default behavior should be in regards to resizing and/or
//       moving existing viewports
//

//- (NFViewportId) addViewportWithRect:(CGRect)rect;
//- (void) removeViewport:(NFViewportId)uniqueId;

@end
