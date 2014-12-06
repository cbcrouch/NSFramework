//
//  NFRenderer.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "NFViewVolume.h"


@interface NFRenderer : NSObject

// instance methods
- (instancetype) init;
- (void) dealloc;

- (void) updateFrameWithTime:(const CVTimeStamp*)outputTime withViewVolume:(NFViewVolume *)viewVolume;

- (void) renderFrame;


//
// TODO: renderer instance should have a more robust viewport interface i.e. can have
//       support for mutliple viewports in the same renderer instance
//
- (void) resizeToRect:(CGRect) rect;


@end
