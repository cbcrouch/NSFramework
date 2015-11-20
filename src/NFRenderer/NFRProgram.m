//
//  NFRProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFSurfaceModel.h"
#import "NFRDataMap.h"

#import "NFRDefaultProgram.h"
#import "NFRDebugProgram.h"


@interface NFRRenderTarget()

@property (nonatomic, assign) GLuint hFBO;

@end

@implementation NFRRenderTarget

@synthesize hFBO = _hFBO;

- (instancetype) init {
    self = [super init];
    if (self != nil) {

        //
        // TODO: create either a texture or render buffer backing for the framebuffer
        //

        // create and initialize render buffer
        GLuint tempRBO;
        glGenRenderbuffers(1, &tempRBO);
        glBindRenderbuffer(GL_RENDERBUFFER, tempRBO);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, 1280, 720);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        CHECK_GL_ERROR();

        // attach render buffer to frame buffer
        GLuint tempFBO;
        glGenFramebuffers(1, &tempFBO);
        _hFBO = tempFBO;
        glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);


        //
        // TODO: add a color attachment
        //

        GLuint textureColorBuffer = 0;


        //
        // TODO: encapsulate generateAttachmentTexture in a class method
        //

        GLboolean depthAttachment = GL_FALSE;
        GLboolean stencilAttachment = GL_FALSE;

        GLenum attachmentType;
        if (!depthAttachment && !stencilAttachment) {
            attachmentType = GL_RGB;
        }
        else if (depthAttachment && !stencilAttachment) {
            attachmentType = GL_DEPTH_COMPONENT;
        }
        else if (!depthAttachment && stencilAttachment) {
            attachmentType = GL_STENCIL_INDEX;
        }

        GLuint textureID;
        glGenTextures(1, &textureID);
        glBindTexture(GL_TEXTURE_2D, textureID);
        if (!depthAttachment && !stencilAttachment) {
            glTexImage2D(GL_TEXTURE_2D, 0, attachmentType, 1280, 720, 0, attachmentType, GL_UNSIGNED_BYTE, NULL);
        }
        else {
            glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH24_STENCIL8, 1280, 720, 0, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, NULL);
        }
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glBindTexture(GL_TEXTURE_2D, 0);


        textureColorBuffer = textureID; //  = [NFRRenderTarget generateAttachmentTextureWithDepth:GL_FALSE withStencil:GL_FALSE];

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureColorBuffer, 0);



        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, tempRBO);

#if 1
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"frame buffer with render buffer attachment is ready to go");
        }
#endif
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);


        CHECK_GL_ERROR();
    }

    return self;
}

- (void) enable {
    glBindFramebuffer(GL_FRAMEBUFFER, self.hFBO);
    CHECK_GL_ERROR();
}

- (void) disable {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    CHECK_GL_ERROR();
}

- (void) dealloc {
    GLuint tempFBO = _hFBO;
    glDeleteFramebuffers(1, &tempFBO);
    CHECK_GL_ERROR();
    [super dealloc];
}

@end



@implementation NFRRenderRequest

@synthesize geometryArray = _geometryArray;

- (NSMutableArray*) geometryArray {
    if (_geometryArray == nil) {
        _geometryArray = [[[NSMutableArray alloc] init] retain];
    }
    return _geometryArray;
}

- (NSMutableArray*) lightsArray {
    if (_lightsArray == nil) {
        _lightsArray = [[[NSMutableArray alloc] init] retain];
    }
    return _lightsArray;
}

- (void) addGeometry:(NFRGeometry*)geometry {
    [self.geometryArray addObject:geometry];

    //
    // TODO: geometry objects should be able to be added to multiple render requests and drawn with
    //       multiple program objects
    //

    //
    // NOTE: geometry will now be bound to the shader program here
    //
    [self.program configureVertexInput:geometry.vertexBuffer.bufferAttributes];
    [self.program configureVertexBufferLayout:geometry.vertexBuffer withAttributes:geometry.vertexBuffer.bufferAttributes];
}

- (void) addLight:(id<NFLightSource>)light {
    [self.lightsArray addObject:light];
}

- (void) process {

    //
    // TODO: loadLight should only be called if the light has been changed (add a dirty flag ??)
    //
    for (id<NFLightSource> light in self.lightsArray) {
        if ([self.program respondsToSelector:@selector(loadLight:)]) {
            [self.program performSelector:@selector(loadLight:) withObject:light];
        }
    }

    for (NFRGeometry* geo in self.geometryArray) {
        [self.program drawGeometry:geo];
    }
}

- (void) dealloc {
    [_geometryArray release];
    [_lightsArray release];
    [super dealloc];
}

@end


//
//
//

@implementation NFRProgram

+ (id<NFRProgram>) createProgramObject:(NSString *)programName {

    if ([programName isEqualToString:@"DefaultModel"]) {
        NFRDefaultProgram* programObj = [[[NFRDefaultProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];
        return programObj;
    }
    else if ([programName isEqualToString:@"Debug"]) {
        NFRDebugProgram* programObj = [[[NFRDebugProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];
        return programObj;
    }
    else {
        NSLog(@"WARNING: NFRUtils createProgramObject attempted to load an unknown program, returning nil");
    }
    
    return nil;
}

@end

