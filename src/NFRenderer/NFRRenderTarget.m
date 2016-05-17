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

@property (nonatomic, assign, readwrite) NFRRenderTargetAttachment_t colorAttachment;
@property (nonatomic, assign, readwrite) NFRRenderTargetAttachment_t depthAttachment;
@property (nonatomic, assign, readwrite) NFRRenderTargetAttachment_t stencilAttachment;
@property (nonatomic, assign, readwrite) NFRRenderTargetAttachment_t depthStencilAttachment;

- (void) tearDown;

@end

@implementation NFRRenderTarget

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

//
// TODO: seperate depth and stencil attachments need to be tested, also should add width and height
//       parameters once this method has been confirmed working for color and depth/stencil attachments
//
- (void) addAttachment:(NFR_ATTACHMENT_TYPE)attachmentType withBackingBuffer:(NFR_TARGET_BUFFER_TYPE)bufferType {
    GLuint tempHandle = 0;
    switch (bufferType) {
        case kRenderBuffer: glGenRenderbuffers(1, &tempHandle); break;
        case kTextureBuffer: glGenTextures(1, &tempHandle); break;
        default:
            NSAssert(nil, @"ERROR: unknown or unsupported buffer type added to render target");
            break;
    }

    NFRRenderTargetAttachment_t tempAttachment;
    tempAttachment.handle = tempHandle;
    tempAttachment.type = bufferType;

    GLenum glInternalStorageType = GL_INVALID_ENUM;
    GLenum glFormatType = GL_INVALID_ENUM;
    GLenum glDataType = GL_INVALID_ENUM;
    GLenum glFrameAttachmentType = GL_INVALID_ENUM;

    //
    // TODO: look into adding support for 32 bit uint depth buffers
    //
    switch (attachmentType) {
        case kColorAttachment:
            glInternalStorageType = GL_RGB;
            glFormatType = GL_RGB;
            glDataType = GL_UNSIGNED_BYTE;

            glFrameAttachmentType = GL_COLOR_ATTACHMENT0;

            self.colorAttachment = tempAttachment;
            break;

        case kDepthAttachment:
            glInternalStorageType = GL_DEPTH_COMPONENT;
            glFormatType = GL_DEPTH_COMPONENT;
            glDataType = GL_FLOAT;

            glFrameAttachmentType = GL_DEPTH_ATTACHMENT;

            self.depthAttachment = tempAttachment;
            break;

        case kStencilAttachment:
            glInternalStorageType = GL_STENCIL;
            glFormatType = GL_STENCIL_INDEX;
            glDataType = GL_UNSIGNED_BYTE;

            glFrameAttachmentType = GL_STENCIL_ATTACHMENT;

            self.stencilAttachment = tempAttachment;
            break;

        case kDepthStencilAttachment:
            glInternalStorageType = GL_DEPTH24_STENCIL8;
            glFormatType = GL_DEPTH_STENCIL;
            glDataType = GL_UNSIGNED_INT_24_8;

            glFrameAttachmentType = GL_DEPTH_STENCIL_ATTACHMENT;

            self.depthStencilAttachment = tempAttachment;
            break;

        default:
            NSAssert(nil, @"ERROR: unknown or unsupported attachment added to render target");
            break;
    }

    if (bufferType == kRenderBuffer) {
        glBindRenderbuffer(GL_RENDERBUFFER, tempHandle);
        glRenderbufferStorage(GL_RENDERBUFFER, glInternalStorageType, self.width, self.height);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);

        // attach render buffer to the frame buffer
        glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, glFrameAttachmentType, GL_RENDERBUFFER, tempHandle);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    else if (bufferType == kTextureBuffer) {
        glBindTexture(GL_TEXTURE_2D, tempHandle);
        glTexImage2D(GL_TEXTURE_2D, 0, glInternalStorageType, self.width, self.height, 0, glFormatType, glDataType, NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        //
        // TODO: this is to ensure that depth maps (primarily used for shadow maps) don't use repeat
        //       which could cause shadowing outside the region for which a light could shadow (this
        //       option/code-path should be made more explicit)
        //
        if(glFormatType == GL_DEPTH_COMPONENT) {

            //
            // TODO: also when the depth map is used as a shadow map will need to write 1.0 values into the
            //       edges of the map to prevent shadows from be extended outside the region of the light caster
            //

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }

        glBindTexture(GL_TEXTURE_2D, 0);

        // attach texture to the frame buffer
        glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);
        glFramebufferTexture2D(GL_FRAMEBUFFER, glFrameAttachmentType, GL_TEXTURE_2D, tempHandle, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    CHECK_GL_ERROR();

    //
    // TODO: move frame buffer complete out to addAttachment or bind call ??
    //
    glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"framebuffer object not complete");
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void) tearDown {

    NSLog(@"WARNING: NFRRenderTarget tearDown called, method is not fully implemented, potential memory leak");

    //
    // TODO: need to clear all attachments is the same manner as the color attachment
    //
    if (self.colorAttachment.handle != 0) {
        NFRRenderTargetAttachment_t tempAttachment;
        tempAttachment.handle = 0;
        tempAttachment.type = self.colorAttachment.type;
        if (self.colorAttachment.type == kTextureBuffer) {
            GLuint tempTex = (GLuint)self.colorAttachment.handle;
            glDeleteTextures(1, &tempTex);
            tempAttachment.handle = tempTex;
        }
        else if (self.colorAttachment.type == kRenderBuffer) {
            GLuint tempRBO = (GLuint)self.colorAttachment.handle;
            glDeleteRenderbuffers(1, &tempRBO);
            tempAttachment.handle = tempRBO;
        }
        self.colorAttachment = tempAttachment;
    }

    // depth attachment

    // stencil attachment

    // depth/stencil attachment

    GLuint tempFBO = self.hFBO;
    glDeleteFramebuffers(1, &tempFBO);
    self.hFBO = tempFBO;

    CHECK_GL_ERROR();
}

- (void) resizeWithWidth:(uint32_t)width withHeight:(uint32_t)height {

    NSLog(@"WARNING: NFRRenderTarget resizeWithWidth called, method is not fully implemented, currently undefined behavior");

    _width = width;
    _height = height;

    //
    // TODO: need to rebuild all active attachments
    //

    // check each attachment handle if valid record the type and backing storage

    // tear down all current attachments

    // re-add the recorded attachments from first step

    [self tearDown];

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
