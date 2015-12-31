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
// - at least one attached buffer (color, depth, or stencil buffer)
// - there should be at least one color attachment
// - all attachments need to be complete (reserved memory)
// - each buffer should have the same number of samples


//
// TODO: consider changing width and height to type GLsizei
//
@property (nonatomic, assign) uint32_t width;
@property (nonatomic, assign) uint32_t height;



//
// TODO: may need to break out the init so there can be a method for adding attachment/buffers
//

- (instancetype) initWithWidth:(uint32_t)width withHeight:(uint32_t)height NS_DESIGNATED_INITIALIZER;
//- (instancetype) initWithWidth:(uint32_t)width withHeight:(uint32_t)height ofBufferType:(NF_BUFFER_TYPE)type;



//
// TODO: should try to avoid having an externally facing enable/disable methods
//
- (void) enable;
- (void) disable;

- (void) resizeWithWidth:(uint32_t)width withHeight:(uint32_t)height;

- (void) addAttachment:(NF_ATTACHMENT_TYPE)attachmentType withBackingBuffer:(NF_BUFFER_TYPE)bufferType;


//
// TODO: would ideally prefer something a little cleaner than passing a raw OpenGL handle
//
@property (nonatomic, readonly) GLuint colorAttachmentHandle;

@end
