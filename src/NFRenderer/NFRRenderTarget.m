//
//  NFRRenderTarget.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFRRenderTarget.h"

#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

#import "NFRUtils.h"

@interface NFRRenderTarget()

@property (nonatomic, assign) GLuint hFBO;

//
// TODO: need a better way to store handles
//
@property (nonatomic, assign) GLuint hRBO;
@property (nonatomic, assign) GLuint hTex;

//
// TODO: should probably be using an array for the attachments
//
@property (nonatomic, assign, readwrite) GLuint colorAttachmentHandle;

@property (nonatomic, assign, readwrite) GLuint depthAttachmentHandle;
@property (nonatomic, assign, readwrite) GLuint stencilAttachmentHandle;
@property (nonatomic, assign, readwrite) GLuint deptjStencilAttachmentHandle;


- (void) buildRenderBufferWithWidth:(uint32_t)width withHeight:(uint32_t)height;
- (void) tearDown;

+ (GLuint) generateAttachmentTextureWithWidth:(uint32_t)width withHeight:(uint32_t)height withDepth:(GLboolean)depthAttachment withStencil:(GLboolean)stencilAttachment;

@end

@implementation NFRRenderTarget

+ (GLuint) generateAttachmentTextureWithWidth:(uint32_t)width withHeight:(uint32_t)height withDepth:(GLboolean)depthAttachment withStencil:(GLboolean)stencilAttachment {
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    if (!depthAttachment && !stencilAttachment) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    }
    else if (depthAttachment && stencilAttachment) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH24_STENCIL8, width, height, 0, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, NULL);
    }
    else if (depthAttachment && !stencilAttachment) {
        //
        // TODO: add support for just creating a depth only attachment
        //
        //glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH, width, height, 0, GL_DEPTH, GL_UNSIGNED_INT, NULL);
    }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);
    CHECK_GL_ERROR();
    return textureID;
}

- (void) setWidth:(uint32_t)width {
    _width = width;
    [self resizeWithWidth:_width withHeight:self.height];
}

- (void) setHeight:(uint32_t)height {
    _height = height;
    [self resizeWithWidth:self.width withHeight:_height];
}

- (instancetype) initWithWidth:(uint32_t)width withHeight:(uint32_t)height {
    self = [super init];
    if (self != nil) {
        _width = width;
        _height = height;

        //
        // TODO: is there a way to an OpenGL FBO to work with GL_FRAMEBUFFER_SRGB ??
        //

        // create frame buffer
        GLuint tempFBO;
        glGenFramebuffers(1, &tempFBO);
        _hFBO = tempFBO;
        CHECK_GL_ERROR();

        [self buildRenderBufferWithWidth:_width withHeight:_height];
    }
    return self;
}

- (instancetype) init {
    //
    // TODO: use global config / default width, height
    //
    self = [self initWithWidth:1280 withHeight:720];
    return self;
}

- (void) dealloc {
    [self tearDown];
}

- (void) addAttachment:(NF_ATTACHMENT_TYPE)attachmentType withBackingBuffer:(NF_BUFFER_TYPE)bufferType {

    //
    // TODO: rename glAttachmentStorageType or similiar
    //
    GLenum glAttachmentType = GL_INVALID_ENUM;

    GLenum glFrameAttachmentType = GL_INVALID_ENUM;
    switch (attachmentType) {
        case kColorAttachment:
            //glAttachmentType = ...
            glFrameAttachmentType = GL_COLOR_ATTACHMENT0;
            break;

        case kDepthAttachment:
            //glAttachmentType = ...
            glFrameAttachmentType = GL_DEPTH_ATTACHMENT;
            break;

        case kStencilAttachment:
            //glAttachmentType = ...
            glFrameAttachmentType = GL_STENCIL_ATTACHMENT;
            break;

        case kDepthStencilAttachment:
            glAttachmentType = GL_DEPTH24_STENCIL8;
            glFrameAttachmentType = GL_DEPTH_STENCIL_ATTACHMENT;
            break;

        default:
            NSAssert(nil, @"ERROR: unknown or unsupported attachment added to render target");
            break;
    }

    //
    // TODO: helper methods for creating buffers, use glAttachmentType and glFrameAttachmentType as inputs
    //

    switch (bufferType) {
        case kRenderBuffer: {
            // create and initialize render buffer
            GLuint tempRBO;
            glGenRenderbuffers(1, &tempRBO);
            self.hRBO = tempRBO;
            glBindRenderbuffer(GL_RENDERBUFFER, self.hRBO);
            glRenderbufferStorage(GL_RENDERBUFFER, glAttachmentType, self.width, self.height);
            glBindRenderbuffer(GL_RENDERBUFFER, 0);

            // attach render buffer to the frame buffer
            glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, glFrameAttachmentType, GL_RENDERBUFFER, self.hRBO);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
        }
        break;

        case kTextureBuffer: {

            //
            // TODO: fold generateAttachmentTexture into here
            //
            self.colorAttachmentHandle = [NFRRenderTarget generateAttachmentTextureWithWidth:self.width
                withHeight:self.height withDepth:GL_FALSE withStencil:GL_FALSE];

            glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);
            glFramebufferTexture2D(GL_FRAMEBUFFER, glFrameAttachmentType, GL_TEXTURE_2D, self.colorAttachmentHandle, 0);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
        }
        break;

        default:
            NSAssert(nil, @"ERROR: unknown or unsupported buffer type added to render target");
            break;
    }
    CHECK_GL_ERROR();


    //
    // TODO: move frame buffer complete out to addAttachment or bind call ??
    //
    glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"framebuffer object not complete");
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

//
// TODO: replace this method with addAttachment
//
- (void) buildRenderBufferWithWidth:(uint32_t)width withHeight:(uint32_t)height {

    NF_BUFFER_TYPE bufferType = kRenderBuffer;

    if (bufferType == kRenderBuffer) {
        // create and initialize render buffer
        GLuint tempRBO;
        glGenRenderbuffers(1, &tempRBO);
        self.hRBO = tempRBO;
        glBindRenderbuffer(GL_RENDERBUFFER, self.hRBO);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        CHECK_GL_ERROR();
    }
    //    else if (self.bufferType == kTextureBuffer) {
    //        // ...
    //    }


    glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);


    if (bufferType == kRenderBuffer) {

        // add a color attachment
        self.colorAttachmentHandle = [NFRRenderTarget generateAttachmentTextureWithWidth:width withHeight:height withDepth:GL_FALSE withStencil:GL_FALSE];
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.colorAttachmentHandle, 0);

        // attach render buffer to frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, self.hRBO);

    }
//    else if (self.bufferType == kTextureBuffer) {
//        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.hTex, 0);
//        //glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, self.hTex, 0);
//
//        self.colorAttachmentHandle = self.hTex;
//    }


    // move frame buffer complete out to addAttachment or bind call ??
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"framebuffer object not complete");

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    CHECK_GL_ERROR();
}

- (void) tearDown {
    GLuint tempTextureID = self.colorAttachmentHandle;
    glDeleteTextures(1, &tempTextureID);
    self.colorAttachmentHandle = tempTextureID;

    //
    // TODO: correctly clean all this up
    //

//    if (self.bufferType == kRenderBuffer) {
//        GLuint tempRBO = self.hRBO;
//        glDeleteRenderbuffers(1, &tempRBO);
//        self.hRBO = tempRBO;
//    }
//    // else ...

    GLuint tempFBO = _hFBO;
    glDeleteFramebuffers(1, &tempFBO);
    self.hFBO = tempFBO;

    CHECK_GL_ERROR();
}

- (void) resizeWithWidth:(uint32_t)width withHeight:(uint32_t)height {
    _width = width;
    _height = height;
    [self tearDown];
    [self buildRenderBufferWithWidth:width withHeight:height];

    //
    // TODO: another strategy is to try creating the largest size framebuffer possible
    //       and applying a scaling factor when converting to screen space
    //
}

- (void) enable {
    glBindFramebuffer(GL_FRAMEBUFFER, self.hFBO);
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"framebuffer object not complete");
    CHECK_GL_ERROR();
}

- (void) disable {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    CHECK_GL_ERROR();
}

@end
