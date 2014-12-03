//
//  NFRenderer.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//


#import <Foundation/Foundation.h>


//
// TODO: won't need these headers anymore after temporary methods have been removed
//
#import "NFProtocols.h"
#import "NFCamera.h"


@interface NFRenderer : NSObject

// instance methods
- (instancetype) init;
- (void) dealloc;

- (void) updateFrameWithTime:(const CVTimeStamp*)outputTime;
- (void) renderFrame;


//
// TODO: renderer instance should have a more robust viewport interface i.e. can have
//       support for mutliple viewports in the same renderer instance
//
- (void) resizeToRect:(CGRect) rect;


//
// TODO: this is a temporary helper method, once the NFViewVolume has been moved
//       out of NFRenderer it won't be needed anymore
//
- (id<NFObserverProtocol>) getCameraObserver;
- (CGRect) getViewportRect;
- (void) bindCamera:(NFCamera *)camera;


//
// TODO: start to break out shims currently located in the renderer into roughly the
//       following subsystems:
//

// NFMechanics
// - entity management system
// - entity state machine parent class
// - cameras


// NFArtificalIntelligence
// - goals and decision making
// - actions (engine interface)
// - path finding
// - sight tracing / perception


// NFPhysicsModel
// - collisions
// - soft bodies
// - etc.

// contact manifolds need to be output to the renderer for deforming meshes


// NFAudio
// - continous output
// - play effect
// - etc.


// should probably break out the scene concept into a high level container
// and a lower level renderer interface that performs occlusion culling etc.

// could be broken into NFResourceCache and NFDisplaySet

// NFScene
// - level
// - display set
// - PVS



//
// TODO: replace these methods with the NFCamera implementation
//
- (void) translateCameraX:(float) value;
- (void) translateCameraY:(float) value;
- (void) translateCameraZ:(float) value;

@end
