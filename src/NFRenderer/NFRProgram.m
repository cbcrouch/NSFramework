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

- (void) buildRenderBufferWithWidth:(uint32_t)width withHeight:(uint32_t)height;
- (void) tearDown;

+ (GLuint) generateAttachmentTextureWithWidth:(uint32_t)width withHeight:(uint32_t)height withDepth:(GLboolean)depthAttachment withStencil:(GLboolean)stencilAttachment;

@property (nonatomic, assign) GLuint hFBO;

@property (nonatomic, assign) GLuint hRBO;
@property (nonatomic, assign) GLuint colorAttachmentTex;

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
    glBindFramebuffer(GL_FRAMEBUFFER, _hFBO);

    // add a color attachment
    _colorAttachmentTex = [NFRRenderTarget generateAttachmentTextureWithWidth:width withHeight:height withDepth:GL_FALSE withStencil:GL_FALSE];
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorAttachmentTex, 0);

    // attach render buffer to frame buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _hRBO);
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"framebuffer object not complete");

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    CHECK_GL_ERROR();
}

- (void) tearDown {
    GLuint tempTextureID = self.colorAttachmentTex;
    glDeleteTextures(1, &tempTextureID);
    [self setColorAttachmentTex:tempTextureID];

    GLuint tempRBO = self.hRBO;
    glDeleteRenderbuffers(1, &tempRBO);
    [self setHRBO:tempRBO];

    GLuint tempFBO = _hFBO;
    glDeleteFramebuffers(1, &tempFBO);
    [self setHFBO:tempFBO];

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

- (void) dealloc {
    [self tearDown];
    [super dealloc];
}

@end



@implementation NFRRenderRequest

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

@interface NFRDisplayTarget()

@property (nonatomic, retain) NFRBufferAttributes* bufferAttributes;
@property (nonatomic, retain) NFRBuffer* vertexBuffer;
@property (nonatomic, retain) NFRBuffer* indexBuffer;

@end


@implementation NFRDisplayTarget

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        
        //
        // TODO: setup texture, and shader
        //

        static const GLfloat quadVertices[] = {
            // position     // texcoord
            -1.0f,  1.0f,   0.0f, 1.0f,
            -1.0f, -1.0f,   0.0f, 0.0f,
             1.0f, -1.0f,   1.0f, 0.0f,

            -1.0f,  1.0f,   0.0f, 1.0f,
             1.0f, -1.0f,   1.0f, 0.0f,
             1.0f,  1.0f,   1.0f, 1.0f
        };
        
        static const GLushort quadIndices[] = {
            0, 1, 2, 3, 4, 5
        };

        NSUInteger numVertices = sizeof(quadVertices)/sizeof(GLfloat);
        NSUInteger numIndices = sizeof(quadIndices)/sizeof(GLushort);

        NF_VERTEX_FORMAT vertexFormat = kVertexFormatScreenSpace;
        _bufferAttributes = [[[NFRBufferAttributes alloc] initWithFormat:vertexFormat] autorelease];

        _vertexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:_bufferAttributes] autorelease];
        _indexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:_bufferAttributes] autorelease];

        [_vertexBuffer loadData:(void *)quadVertices ofType:kBufferDataTypeNFScreenSpaceVertex_t numberOfElements:numVertices];
        [_indexBuffer loadData:(void *)quadIndices ofType:kBufferDataTypeUShort numberOfElements:numIndices];
    }
    return self;
}

- (void) display {
    //
    // TODO: need a shader and some boilerplate code to transfer the contents of the
    //       render buffer to the screen (the shader used for this will also be used
    //       for any post-processing algorithms)
    //

    // bind screen shader
    // clear screen
    // draw othrographic screen space triangles with frame buffer texture
    // release all binds
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

