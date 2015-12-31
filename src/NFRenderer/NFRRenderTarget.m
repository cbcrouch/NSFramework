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

@property (nonatomic, assign) NF_BUFFER_TYPE bufferType;
@property (nonatomic, assign) GLuint hRBO;
@property (nonatomic, assign) GLuint hTex;

//
// TODO: add a handle for accessing the depth and stencil attachment
//
@property (nonatomic, assign, readwrite) GLuint colorAttachmentHandle;

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

//
// TODO: add an init method that has width and height params
//

- (instancetype) initWithWidth:(uint32_t)width withHeight:(uint32_t)height {
    self = [super init];
    if (self != nil) {
        //
        // TODO: add support for different types/formats of framebuffers and render-to-texture
        //
        _width = width;
        _height = height;
        [self buildRenderBufferWithWidth:_width withHeight:_height];
    }
    return self;
}

- (instancetype) init {
    self = [self initWithWidth:1280 withHeight:720];
    return self;
}

//
// TODO: add param indicating buffer type and use for render to texture
//
- (void) buildRenderBufferWithWidth:(uint32_t)width withHeight:(uint32_t)height {


    self.bufferType = kRenderBuffer;


    NFFrameBacking_t colorTetxture;
    colorTetxture.bufferType = kTextureBuffer;
    colorTetxture.attachmentType = kColorAttachment;

    NFFrameBacking_t depthStencil;
    depthStencil.bufferType = kRenderBuffer;
    depthStencil.attachmentType = kDepthStencilAttachment;


    //
    // TODO: is there a way to an OpenGL FBO to work with GL_FRAMEBUFFER_SRGB ??
    //

    // create frame buffer
    GLuint tempFBO;
    glGenFramebuffers(1, &tempFBO);
    _hFBO = tempFBO;


    if (self.bufferType == kRenderBuffer) {
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


    //
    // TODO: need to update options to configure both attachments to use and the backings for each
    //

    if (self.bufferType == kRenderBuffer) {

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

    if (self.bufferType == kRenderBuffer) {
        GLuint tempRBO = self.hRBO;
        glDeleteRenderbuffers(1, &tempRBO);
        self.hRBO = tempRBO;
    }
    // else ...

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

- (void) addAttachment:(NF_ATTACHMENT_TYPE)attachmentType withBackingBuffer:(NF_BUFFER_TYPE)bufferType {
    //
    // TODO: add an attachment to the framebuffer object
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

- (GLuint) getColorAttachmentHandle {
    return self.colorAttachmentHandle;
}

- (void) dealloc {
    [self tearDown];
}

@end
