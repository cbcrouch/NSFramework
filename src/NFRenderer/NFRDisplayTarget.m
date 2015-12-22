//
//  NFRDisplayTarget.m
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import "NFRDisplayTarget.h"

#import "NFRUtils.h"
#import "NFRResources.h"


@interface NFRDisplayTarget()

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, assign) GLuint transferTexHandle;

@property (nonatomic, retain) NFRBuffer* vertexBuffer;
@property (nonatomic, retain) NFRBuffer* indexBuffer;

@end


@implementation NFRDisplayTarget

- (void) setTransferSource:(NFRRenderTarget *)transferSource {
    _transferSource = transferSource;
    [self setTransferTexHandle:transferSource.getColorAttachmentHandle];
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        _program = [[NFRUtils createProgramObject:@"Display"] retain];

        NFScreenSpaceVertex_t quadVertices[6];

        // first triangle
        quadVertices[0].pos[0] = -1.0f;
        quadVertices[0].pos[1] = 1.0f;
        quadVertices[0].texCoord[0] = 0.0f;
        quadVertices[0].texCoord[1] = 1.0f;

        quadVertices[1].pos[0] = -1.0f;
        quadVertices[1].pos[1] = -1.0f;
        quadVertices[1].texCoord[0] = 0.0f;
        quadVertices[1].texCoord[1] = 0.0f;

        quadVertices[2].pos[0] = 1.0f;
        quadVertices[2].pos[1] = -1.0f;
        quadVertices[2].texCoord[0] = 1.0f;
        quadVertices[2].texCoord[1] = 0.0f;

        // second triangle
        quadVertices[3].pos[0] = -1.0f;
        quadVertices[3].pos[1] = 1.0f;
        quadVertices[3].texCoord[0] = 0.0f;
        quadVertices[3].texCoord[1] = 1.0f;

        quadVertices[4].pos[0] = 1.0f;
        quadVertices[4].pos[1] = -1.0f;
        quadVertices[4].texCoord[0] = 1.0f;
        quadVertices[4].texCoord[1] = 0.0f;

        quadVertices[5].pos[0] = 1.0f;
        quadVertices[5].pos[1] = 1.0f;
        quadVertices[5].texCoord[0] = 1.0f;
        quadVertices[5].texCoord[1] = 1.0f;

        static const GLushort quadIndices[] = {
            0, 1, 2, 3, 4, 5
        };

        NSUInteger numVertices = sizeof(quadVertices)/sizeof(GLfloat);
        NSUInteger numIndices = sizeof(quadIndices)/sizeof(GLushort);

        NF_VERTEX_FORMAT vertexFormat = kVertexFormatScreenSpace;
        NFRBufferAttributes* bufferAttributes = [[[NFRBufferAttributes alloc] initWithFormat:vertexFormat] autorelease];

        _vertexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttributes] retain];
        _indexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttributes] retain];

        [_vertexBuffer loadData:(void *)quadVertices ofType:kBufferDataTypeNFScreenSpaceVertex_t numberOfElements:numVertices];
        [_indexBuffer loadData:(void *)quadIndices ofType:kBufferDataTypeUShort numberOfElements:numIndices];
    }
    return self;
}

- (void) dealloc {
    [_vertexBuffer release];
    [_indexBuffer release];

    [super dealloc];
}

- (void) processTransfer {
    NSAssert(self.transferSource != nil, @"attempted to use display target without setting a transfer source");

    //
    // TODO: this is really inefficient and should be fixed
    //
    [self.program configureVertexInput:self.vertexBuffer.bufferAttributes];
    [self.program configureVertexBufferLayout:self.vertexBuffer withAttributes:self.vertexBuffer.bufferAttributes];

    glUseProgram(self.program.hProgram);
    glBindVertexArray(self.vertexBuffer.bufferAttributes.hVAO);
    glDisable(GL_DEPTH_TEST);

    glBindTexture(GL_TEXTURE_2D, self.transferTexHandle);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer.bufferHandle);
    glDrawElements(GL_TRIANGLES, (GLsizei)self.indexBuffer.numberOfElements, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    glEnable(GL_DEPTH_TEST);
    glBindVertexArray(0);
    glUseProgram(0);

    CHECK_GL_ERROR();
}

@end
