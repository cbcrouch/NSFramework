//
//  NFRRenderTarget.h
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NFRRenderTarget : NSObject

typedef NS_ENUM(NSUInteger, NF_BUFFER_TYPE) {
    kTextureBuffer,
    kRenderBuffer
};

typedef NS_ENUM(NSUInteger, NF_ATTACHMENT_TYPE) {
    kColorAttachment,
    kDepthAttachment,
    kStencilAttachment,
    kDepthStencilAttachment
};

typedef struct NFFrameBacking_t {
    NF_BUFFER_TYPE bufferType;
    NF_ATTACHMENT_TYPE attachmentType;
} NFFrameBacking_t;



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

- (void) addAttachment:(NF_ATTACHMENT_TYPE)attachmentType withBackingBuffer:(NF_BUFFER_TYPE)bufferType;


//
// TODO: should try to avoid having an externally facing enable/disable methods
//
- (void) enable;
- (void) disable;


@property (nonatomic, assign, readonly) GLuint colorAttachmentHandle;

@property (nonatomic, assign, readonly) GLuint depthAttachmentHandle;
@property (nonatomic, assign, readonly) GLuint stencilAttachmentHandle;
@property (nonatomic, assign, readonly) GLuint deptjStencilAttachmentHandle;

@end
