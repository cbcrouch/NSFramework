//
//  NFRDisplayTarget.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFRDisplayTarget.h"

#import "NFRUtils.h"
#import "NFRResources.h"

#import "NFRDisplayProgram.h"

@interface NFRDisplayTarget()

@property (nonatomic, strong) id<NFRProgram> program;
@property (nonatomic, assign) GLuint transferTexHandle;

@property (nonatomic, strong) NFRBuffer* vertexBuffer;
@property (nonatomic, strong) NFRBuffer* indexBuffer;

@end


@implementation NFRDisplayTarget

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        _program = [NFRUtils createProgramObject:@"Display"];

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
        NFRBufferAttributes* bufferAttributes = [[NFRBufferAttributes alloc] initWithFormat:vertexFormat];

        _vertexBuffer = [[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttributes];
        _indexBuffer = [[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttributes];

        [_vertexBuffer loadData:(void *)quadVertices ofType:kBufferDataTypeNFScreenSpaceVertex_t numberOfElements:numVertices];
        [_indexBuffer loadData:(void *)quadIndices ofType:kBufferDataTypeUShort numberOfElements:numIndices];
    }
    return self;
}

- (void) processTransferOfAttachment:(NFR_ATTACHMENT_TYPE)attachmentType {
    NSAssert(self.transferSource != nil, @"attempted to use display target without setting a transfer source");

    switch (attachmentType) {
        case kColorAttachment:
            self.transferTexHandle = (GLuint)self.transferSource.colorAttachment.handle;
            break;

        case kDepthAttachment:
            self.transferTexHandle = (GLuint)self.transferSource.depthAttachment.handle;
            break;

        case kStencilAttachment:
            self.transferTexHandle = (GLuint)self.transferSource.stencilAttachment.handle;
            break;

        case kDepthStencilAttachment:
            self.transferTexHandle = (GLuint)self.transferSource.depthStencilAttachment.handle;
            break;

        default:
            break;
    }

    //
    // TODO: this is really inefficient and should be fixed
    //
    [self.program configureVertexInput:self.vertexBuffer.bufferAttributes];
    [self.program configureVertexBufferLayout:self.vertexBuffer withAttributes:self.vertexBuffer.bufferAttributes];

    glDisable(GL_DEPTH_TEST);
    glUseProgram(self.program.hProgram);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.transferTexHandle);

    //
    // TODO: should probably store the program as a NFRDisplayProgram object to avoiding this cast every frame
    //
    glUniform1i(((NFRDisplayProgram*)self.program).textureUniform, 0);

    glBindVertexArray(self.vertexBuffer.bufferAttributes.hVAO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer.bufferHandle);
    glDrawElements(GL_TRIANGLES, (GLsizei)self.indexBuffer.numberOfElements, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    glBindVertexArray(0);
    glUseProgram(0);
    glEnable(GL_DEPTH_TEST);

    CHECK_GL_ERROR();
}

@end
