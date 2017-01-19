//
//  NFRRenderTarget.h
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NFRRenderTarget : NSObject

typedef NS_ENUM(NSUInteger, NFR_TARGET_BUFFER_TYPE) {
    kTextureBuffer,
    kCubeMapBuffer,
    kRenderBuffer
};

typedef NS_ENUM(NSUInteger, NFR_ATTACHMENT_TYPE) {
    kColorAttachment,
    kDepthAttachment,
    kStencilAttachment,
    kDepthStencilAttachment
};


//
// TODO: use this struct for attachment handles (could also use a better name
//
typedef struct NFRRenderTargetAttachment_t {
    NSUInteger handle;
    NFR_TARGET_BUFFER_TYPE type;
} NFRRenderTargetAttachment_t;


// for a framebuffer to be complete it needs at least
// - one attached buffer (color, depth, or stencil buffer)
// - there should be at least one color attachment
// - all attachments need to be complete (reserved memory)
// - each buffer should have the same number of samples


//
// TODO: consider changing width and height to type GLsizei
//
@property (nonatomic, assign) uint32_t width;
@property (nonatomic, assign) uint32_t height;

- (instancetype) initWithWidth:(uint32_t)width withHeight:(uint32_t)height NS_DESIGNATED_INITIALIZER;

- (void) resizeWithWidth:(uint32_t)width withHeight:(uint32_t)height;

- (void) addAttachment:(NFR_ATTACHMENT_TYPE)attachmentType withBackingBuffer:(NFR_TARGET_BUFFER_TYPE)bufferType;


//
// TODO: should try to avoid having an externally facing enable/disable methods
//
- (void) enable;
- (void) disable;


@property (nonatomic, assign, readonly) NFRRenderTargetAttachment_t colorAttachment;
@property (nonatomic, assign, readonly) NFRRenderTargetAttachment_t depthAttachment;
@property (nonatomic, assign, readonly) NFRRenderTargetAttachment_t stencilAttachment;
@property (nonatomic, assign, readonly) NFRRenderTargetAttachment_t depthStencilAttachment;

@end
