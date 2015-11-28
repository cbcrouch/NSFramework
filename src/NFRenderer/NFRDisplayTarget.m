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
{
    __block NFRBuffer* vertexBufferRef;
    __block NFRBuffer* indexBufferRef;
}

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, assign) GLuint transferTexHandle;

@property (nonatomic, retain) NFRBuffer* vertexBuffer;
@property (nonatomic, retain) NFRBuffer* indexBuffer;

@end


@implementation NFRDisplayTarget

/*
 + (void) testBlock:(void (^)(void))block {
 block();
 }
 */

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

        _vertexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttributes] autorelease];
        _indexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttributes] autorelease];

        [_vertexBuffer loadData:(void *)quadVertices ofType:kBufferDataTypeNFScreenSpaceVertex_t numberOfElements:numVertices];
        [_indexBuffer loadData:(void *)quadIndices ofType:kBufferDataTypeUShort numberOfElements:numIndices];


/*
        //__block NFRBuffer* vertexBufferRef = _vertexBuffer;
        //__block NFRBuffer* indexBufferRef = _indexBuffer;
        vertexBufferRef = _vertexBuffer;
        indexBufferRef = _indexBuffer;

        [NFRDisplayTarget testBlock:^{
            NSLog(@"vertex buffer ref handle: %d", vertexBufferRef.bufferHandle);
            NSLog(@"index buffer ref handle: %d", indexBufferRef.bufferHandle);
        }];
*/
    }
    return self;
}

- (void) display {

    //
    // TODO: need a shader and some boilerplate code to transfer the contents of the
    //       render buffer to the screen (the shader used for this will also be used
    //       for any post-processing algorithms)
    //

    NSAssert(self.transferSource != nil, @"attempted to use display target without setting a transfer source");
}

@end
