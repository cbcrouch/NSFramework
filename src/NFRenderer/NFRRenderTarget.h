//
//  NFRRenderTarget.h
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

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


//
// TODO: would ideally prefer something a little cleaner than passing a raw OpenGL handle
//
@property (nonatomic, getter=getColorAttachmentHandle, readonly) GLuint colorAttachmentHandle;

@end
