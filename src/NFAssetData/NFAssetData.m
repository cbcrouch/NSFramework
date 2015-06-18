//
//  NSAssetData.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"

//
// TODO: find out who is including gl.h into the project (might be the display link...), one way around all this
//       might be to skip the provided OpenGL header file and use a custom loader
//

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>
#import <GLKit/GLKit.h>


@interface NFAssetData()

@property (nonatomic, assign) GLuint hVAO;

//
// TODO: need to come up with a good way of correlating texture handles with
//       surface model data
//
@property (nonatomic, assign) GLuint textureId;
@property (nonatomic, assign) GLint textureUniform;

@end

@implementation NFAssetData

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _subsetArray = nil;
    _modelMatrix = GLKMatrix4Identity;
    return self;
}

- (void) dealloc {
    [super dealloc];
}

- (void) stepTransforms:(float)secsElapsed {

    //
    // TODO: this "animation" is currently hardcoded, need to design something simple
    //       for getting/setting a transform heirarchy and providing step/update functionality
    //

    //
    // TODO: perform rotation with quaternions if GLK implementation doesn't prevent
    //       gimbal lock with GLKMatrix4Rotate
    //

    float angle = secsElapsed * M_PI_4;
    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] subsetModelMat];
    [[self.subsetArray objectAtIndex:0] setSubsetModelMat:GLKMatrix4RotateY(model, angle)];
}

- (void) applyUnitScalarMatrix {
    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] unitScalarMatrix];
    //[[self.subsetArray objectAtIndex:0] setUnitScalarMatrix:[[self.subsetArray objectAtIndex:0] modelMatrix]];
    [[self.subsetArray objectAtIndex:0] setSubsetModelMat:model];
}

- (void) applyOriginCenterMatrix {
    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] originCenterMatrix];
    //[[self.subsetArray objectAtIndex:0] setOriginCenterMatrix:[[self.subsetArray objectAtIndex:0] modelMatrix]];
    [[self.subsetArray objectAtIndex:0] setSubsetModelMat:model];
}


- (void) bindAssetToProgramObj:(id<NFRProgram>)programObj {
    // create VAO
    GLuint vao;
    glGenVertexArrays(1, &(vao));
    self.hVAO = vao;



    //
    // TODO: rough usage code
    //
    NFRBufferAttributes* bufferAttribs = [[[NFRBufferAttributes alloc] initWithFormat:kVertexFormatDefault] autorelease];

    NFRBuffer* vertexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttribs] autorelease];
    NFRBuffer* indexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttribs] autorelease];

    [vertexBuffer loadData:NULL ofType:kBufferDataTypeNFVertex_t numberOfElements:0];
    [indexBuffer loadData:NULL ofType:kBufferDataTypeUShort numberOfElements:0];

    NFRGeometry* geometry = [[[NFRGeometry alloc] init] autorelease];
    [geometry setVertexBuffer:vertexBuffer];
    [geometry setIndexBuffer:indexBuffer];

    //
    // TODO: need to debug why these aren't working correctly
    //
    //[programObj configureVertexInput:bufferAttribs];
    //[programObj configureVertexBufferLayout:vertexBuffer withAttributes:bufferAttribs];


    //
    // TODO: will either want a geometry subset or geometry hierarchy structure object to apply transform hierarchies to
    //



    [programObj configureInputState:self.hVAO];



    //
    // TODO: should only perform texture setup if the asset and shader both support it, need to focus
    //       on removing/moving texture code out of the asset data
    //

    // first need some way to determine if asset has any valid textures (will also need to know if
    // the asset has data stored in the debug format)

    // get texture unifrom location
    self.textureUniform = glGetUniformLocation(programObj.hProgram, (const GLchar *)"texSampler\0");
    NSAssert(self.textureUniform != -1, @"Failed to get texture uniform location");



    for (NFAssetSubset *subset in self.subsetArray) {
        [subset bindSubsetToProgramObj:programObj withVAO:self.hVAO];

        NFSurfaceModel *surface = [subset surfaceModel];
        if (surface) {
            NFRDataMap *diffuseMap = [surface map_Kd];

            //
            // TODO: integrate the data map into the NFRGeometry object
            //
            GLuint texId;
            glGenTextures(1, &texId);
            self.textureId = texId;

            //
            // TODO: use glTextureStorage2D specify texture storage requirements
            //       since for most cases they should be known
            //

            glBindTexture(GL_TEXTURE_2D, self.textureId);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexImage2D(GL_TEXTURE_2D, 0, [diffuseMap format], [diffuseMap width], [diffuseMap height], 0,
                         [diffuseMap format], [diffuseMap type], [diffuseMap data]);
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }
}

- (void) drawWithProgramObject:(id<NFRProgram>)programObj withSubroutine:(NSString*)subroutine {
    //
    // TODO: need to test and abstract out the texture/sampler logic into a NFRTexture and NFRSampler class
    //

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureId);
    glUniform1i(self.textureUniform, 0); // GL_TEXTURE0


    //
    // TODO: temporary set the program subroutine here
    //
    if ([programObj respondsToSelector:@selector(activateSubroutine:)]) {
        [programObj activateSubroutine:subroutine];
    }


    //
    // TODO: the VAO needs to be bound when issuing a draw call, this needs to be better abstracted so that the
    //       NFAssetData doesn't need to deal with VAO handles
    //
    glBindVertexArray(self.hVAO);

    for (NFAssetSubset *subset in self.subsetArray) {
        [subset drawWithProgram:programObj withAssetModelMatrix:self.modelMatrix];
    }

    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

@end
