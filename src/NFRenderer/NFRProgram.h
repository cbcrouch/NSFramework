//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


#import "NFLightSource.h"

#import "NFRResources.h"
#import "NFRProgramProtocol.h"


//
// TODO: move the render target, render request, and viewport classes into their own separate files
//


@interface NFRRenderTarget : NSObject

typedef NS_ENUM(NSUInteger, TARGET_TYPE) {
    //
    // TODO: need format types for render buffer and texture targets
    //
    kColorBuffer,
    kDepthBuffer,
    kStencilBuffer
};

typedef NS_ENUM(NSUInteger, BUFFER_TYPE) {
    kTextureBuffer,
    kRenderBuffer
};

// for a framebuffer to be complete it needs at least
// - at least one attached buffer (color, depth, or stencil buffer)
// - there should be at least one color attachment
// - all attachments need to be complete (reserved memory)
// - each buffer should have the same number of samples


//
// TODO: consider changing width and height to type GLsizei
//
@property (nonatomic, assign) uint32_t width;
@property (nonatomic, assign) uint32_t height;

//- (instancetype) initWithWidth:(uint32_t)width withHeight:(uint32_t)height;

//
// TODO: should try to avoid having an externally facing enable/disable methods
//
- (void) enable;
- (void) disable;

- (void) resizeWithWidth:(uint32_t)width withHeight:(uint32_t)height;

@end


// alternative names
// - NFRScreenTransfer
// - NFRDisplayTransfer
// - NFRPixelTransfer
// - NFRDisplayTarget
// - NFRPostProcessor

@interface NFRViewport : NSObject


@property (nonatomic, assign) GLsizei originX;
@property (nonatomic, assign) GLsizei originY;
@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;

@property (nonatomic, retain) NFRRenderTarget* displayTarget;

- (void) display;

@end



@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, retain) NSMutableArray* geometryArray;
@property (nonatomic, retain) NSMutableArray* lightsArray;

@property (nonatomic, retain) NFRRenderTarget* renderTarget;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) addLight:(id<NFLightSource>)light;

//
// TODO: set renderTarget function
//

- (void) process;

@end



@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end
