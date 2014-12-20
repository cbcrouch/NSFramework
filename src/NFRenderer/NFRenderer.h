//
//  NFRenderer.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
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

- (instancetype) init;

//
// TODO: should the renderer own the viewport dimensions or the view volume ??
//
//- (instancetype) initWithWidth:(NSInteger)width withHeight(NSInteger)height;
//- (instancetype) initWithViewport:(NSRect)viewportRect;

- (void) dealloc;

- (void) updateFrameWithTime:(const CVTimeStamp*)outputTime withViewMatrix:(GLKMatrix4)viewMatrix
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
