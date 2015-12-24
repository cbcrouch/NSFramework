//
//  NFRRenderTarget.m
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import "NFRRenderTarget.h"

#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

#import "NFRUtils.h"

@interface NFRRenderTarget()

- (void) buildRenderBufferWithWidth:(uint32_t)width withHeight:(uint32_t)height;
- (void) tearDown;

+ (GLuint) generateAttachmentTextureWithWidth:(uint32_t)width withHeight:(uint32_t)height withDepth:(GLboolean)depthAttachment withStencil:(GLboolean)stencilAttachment;

@property (nonatomic, assign) GLuint hFBO;

@property (nonatomic, assign) GLuint hRBO;
@property (nonatomic, assign) GLuint colorAttachmentHandle;

@end

@implementation NFRRenderTarget

+ (GLuint) generateAttachmentTextureWithWidth:(uint32_t)width withHeight:(uint32_t)height withDepth:(GLboolean)depthAttachment withStencil:(GLboolean)stencilAttachment {
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    if (!depthAttachment && !stencilAttachment) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    }
    else {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH24_STENCIL8, width, height, 0, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, NULL);
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

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: add support for different types/formats of framebuffers and render-to-texture
        //
        _width = 1280;
        _height = 720;
        [self buildRenderBufferWithWidth:_width withHeight:_height];
    }

    return self;
}

- (void) buildRenderBufferWithWidth:(uint32_t)width withHeight:(uint32_t)height {
    // create and initialize render buffer
    GLuint tempRBO;
    glGenRenderbuffers(1, &tempRBO);
    _hRBO = tempRBO;
    glBindRenderbuffer(GL_RENDERBUFFER, _hRBO);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    CHECK_GL_ERROR();

    // create frame buffer
    GLuint tempFBO;
    glGenFramebuffers(1, &tempFBO);
    _hFBO = tempFBO;

    //
    // TODO: is there a way to an OpenGL FBO to work with GL_FRAMEBUFFER_SRGB ??
    //
    glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);

    // add a color attachment
    _colorAttachmentHandle = [NFRRenderTarget generateAttachmentTextureWithWidth:width withHeight:height withDepth:GL_FALSE withStencil:GL_FALSE];
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorAttachmentHandle, 0);

    // attach render buffer to frame buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _hRBO);
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"framebuffer object not complete");

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    CHECK_GL_ERROR();
}

- (void) tearDown {
    GLuint tempTextureID = self.colorAttachmentHandle;
    glDeleteTextures(1, &tempTextureID);
    self.colorAttachmentHandle = tempTextureID;

    GLuint tempRBO = self.hRBO;
    glDeleteRenderbuffers(1, &tempRBO);
    self.hRBO = tempRBO;

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
    [super dealloc];
}

@end
