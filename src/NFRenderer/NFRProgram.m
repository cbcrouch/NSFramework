//
//  NFRProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"


@interface NFRPhongProgram : NSObject <NFRProgram>

typedef struct phongMaterialUniform_t {
    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;
    GLint shineLoc;
} phongMaterialUniform_t;

typedef struct phongLightUniform_t {
    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;
    GLint positionLoc;
} phongLightUniform_t;

@property (nonatomic, assign) GLint vertexAttribute;
@property (nonatomic, assign) GLint normalAttribute;
@property (nonatomic, assign) GLint texCoordAttribute;

@property (nonatomic, assign) phongMaterialUniform_t materialUniforms;
@property (nonatomic, assign) phongLightUniform_t lightUniforms;

@property (nonatomic, assign) GLint modelMatrixLocation;
@property (nonatomic, assign) GLint viewPositionLocation;
@property (nonatomic, assign) GLuint lightSubroutine;
@property (nonatomic, assign) GLuint phongSubroutine;

@property (nonatomic, assign) GLuint hUBO;

@property (nonatomic, readwrite, assign) GLuint hProgram;

- (void) loadProgramInputPoints;

@end

@implementation NFRPhongProgram

@synthesize vertexAttribute = _vertexAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize texCoordAttribute = _texCoordAttribute;

@synthesize materialUniforms = _materialUniforms;
@synthesize lightUniforms = _lightUniforms;

@synthesize modelMatrixLocation = _modelMatrixLocation;
@synthesize viewPositionLocation = _viewPositionLocation;
@synthesize lightSubroutine = _lightSubroutine;
@synthesize phongSubroutine = _phongSubroutine;

@synthesize hUBO = _hUBO;

- (void) loadProgramInputPoints {
    // shader attributes
    [self setVertexAttribute:glGetAttribLocation(self.hProgram, "v_position")];
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    [self setNormalAttribute:glGetAttribLocation(self.hProgram, "v_normal")];
    NSAssert(self.normalAttribute != -1, @"Failed to bind attribute");

    [self setTexCoordAttribute:glGetAttribLocation(self.hProgram, "v_texcoord")];
    NSAssert(self.texCoordAttribute != -1, @"Failed to bind attribute");

    // material struct uniform locations
    phongMaterialUniform_t phongMat;

    phongMat.ambientLoc = glGetUniformLocation(self.hProgram, "material.ambient");
    NSAssert(phongMat.ambientLoc != -1, @"failed to get uniform location");

    phongMat.diffuseLoc = glGetUniformLocation(self.hProgram, "material.diffuse");
    NSAssert(phongMat.diffuseLoc != -1, @"failed to get uniform location");

    phongMat.specularLoc = glGetUniformLocation(self.hProgram, "material.specular");
    NSAssert(phongMat.specularLoc != -1, @"failed to get uniform location");

    phongMat.shineLoc = glGetUniformLocation(self.hProgram, "material.shininess");
    NSAssert(phongMat.shineLoc != -1, @"failed to get uniform location");

    [self setMaterialUniforms:phongMat];

    // hardcoded material values (jade)
    glUseProgram(self.hProgram);
    glUniform3f(phongMat.ambientLoc, 0.135f, 0.2225f, 0.1575f);
    glUniform3f(phongMat.diffuseLoc, 0.54f, 0.89f, 0.63f);
    glUniform3f(phongMat.specularLoc, 0.316228f, 0.316228f, 0.316228f);
    glUniform1f(phongMat.shineLoc, 128.0f * 0.1f);
    glUseProgram(0);

    // light struct uniform locations
    phongLightUniform_t phongLight;
    phongLight.ambientLoc = glGetUniformLocation(self.hProgram, "light.ambient");
    NSAssert(phongLight.ambientLoc != -1, @"failed to get uniform location");

    phongLight.diffuseLoc = glGetUniformLocation(self.hProgram, "light.diffuse");
    NSAssert(phongLight.diffuseLoc != -1, @"failed to get uniform location");

    phongLight.specularLoc = glGetUniformLocation(self.hProgram, "light.specular");
    NSAssert(phongLight.specularLoc != -1, @"failed to get uniform location");

    phongLight.positionLoc = glGetUniformLocation(self.hProgram, "light.position");
    NSAssert(phongLight.positionLoc != -1, @"failed to get uniform location");

    [self setLightUniforms:phongLight];

    // hardcoded light values
    glUseProgram(self.hProgram);
    glUniform3f(phongLight.ambientLoc, 0.2f, 0.2f, 0.2f);
    glUniform3f(phongLight.diffuseLoc, 0.5f, 0.5f, 0.5f);
    glUniform3f(phongLight.specularLoc, 1.0f, 1.0f, 1.0f);
    glUniform3f(phongLight.positionLoc, 2.0f, 1.0f, 0.0f);
    glUseProgram(0);

    // model matrix uniform location
    [self setModelMatrixLocation:glGetUniformLocation(self.hProgram, (const GLchar *)"model")];
    NSAssert(self.modelMatrixLocation != -1, @"failed to get model matrix uniform location");

    // view position uniform location
    [self setViewPositionLocation:glGetUniformLocation(self.hProgram, "viewPos")];
    NSAssert(self.viewPositionLocation != -1, @"failed to get uniform location");

    // subroutine indices
    [self setLightSubroutine:glGetSubroutineIndex(self.hProgram, GL_FRAGMENT_SHADER, "light_subroutine")];
    NSAssert(self.lightSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    [self setPhongSubroutine:glGetSubroutineIndex(self.hProgram, GL_FRAGMENT_SHADER, "phong_subroutine")];
    NSAssert(self.phongSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    // uniform buffer for view and projection matrix
    [self setHUBO:[NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:self.hProgram]];
    NSAssert(self.hUBO != 0, @"failed to get uniform buffer handle");
}


//
// TODO: protocol region
//

@synthesize hProgram = _hProgram;

/*
- (void) setStateWithVAO:(GLint)hVAO withVBO:(GLint)hVBO {
    glBindVertexArray(hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.texCoordAttribute);


    glBindBuffer(GL_ARRAY_BUFFER, hVBO);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));
    glVertexAttribPointer(self.normalAttribute, ARRAY_COUNT(NFVertex_t, norm), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, norm));
    glVertexAttribPointer(self.texCoordAttribute, ARRAY_COUNT(NFVertex_t, texCoord), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, texCoord));

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindVertexArray(0);

}
*/

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {

    //
    // TODO: while not yet implemented should consider using some additional utility methods
    //       for simplfying UBOs to avoid redundant code between shader program implementations
    //


/*
    static const char* matrixType = @encode(GLKMatrix4);
    NSMutableArray* matrixArray = [[[NSMutableArray alloc] init] autorelease];
    [matrixArray addObject:[NSValue value:&viewMatrix withObjCType:matrixType]];
    [matrixArray addObject:[NSValue value:&projection withObjCType:matrixType]];

    //
    // TODO: this has not been tested
    //
    [NFRUtils setUniformBuffer:self.hUBO withData:matrixArray];
*/


    GLsizeiptr matrixSize = (GLsizeiptr)(16 * sizeof(float));
    GLintptr offset = (GLintptr)matrixSize;

    glBindBuffer(GL_UNIFORM_BUFFER, self.hUBO);

    // will allocate buffer's internal storage
    glBufferData(GL_UNIFORM_BUFFER, 2 * matrixSize, NULL, GL_STATIC_READ);

    // transfer view and projection matrix data to uniform buffer
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, matrixSize, viewMatrix.m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, matrixSize, projection.m);

    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    CHECK_GL_ERROR();
}

@end


@interface NFRDebugProgram : NSObject <NFRProgram>

@property (nonatomic, assign) GLint vertexAttribute;
@property (nonatomic, assign) GLint normalAttribute;
@property (nonatomic, assign) GLint colorAttribute;

@property (nonatomic, assign) GLint modelMatrixLocation;

@property (nonatomic, assign) GLuint hUBO;

@property (nonatomic, readwrite, assign) GLuint hProgram;

- (void) loadProgramInputPoints;

@end

@implementation NFRDebugProgram

@synthesize vertexAttribute = _vertexAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize colorAttribute = _colorAttribute;

@synthesize modelMatrixLocation = _modelMatrixLocation;

@synthesize hUBO = _hUBO;


- (void) loadProgramInputPoints {
    // shader attributes
    [self setVertexAttribute:glGetAttribLocation(self.hProgram, "v_position")];
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    [self setNormalAttribute:glGetAttribLocation(self.hProgram, "v_normal")];
    NSAssert(self.normalAttribute != -1, @"Failed to bind attribute");

    [self setColorAttribute:glGetAttribLocation(self.hProgram, "v_color")];
    NSAssert(self.colorAttribute != -1, @"Failed to bind attribute");

    // setup uniform for model matrix
    [self setModelMatrixLocation:glGetUniformLocation(self.hProgram, (const GLchar *)"model")];
    NSAssert(self.modelMatrixLocation != -1, @"Failed to get model matrix uniform location");

    // uniform buffer for view and projection matrix
    [self setHUBO:[NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:self.hProgram]];
    NSAssert(self.hUBO != 0, @"failed to get uniform buffer handle");
}


@synthesize hProgram = _hProgram;

/*
- (void) setStateWithVAO:(GLint)hVAO withVBO:(GLint)hVBO {

    glBindVertexArray(hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.colorAttribute);


    glBindBuffer(GL_ARRAY_BUFFER, hVBO);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFDebugVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFDebugVertex_t, pos));
    glVertexAttribPointer(self.normalAttribute, ARRAY_COUNT(NFDebugVertex_t, norm), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFDebugVertex_t, norm));
    glVertexAttribPointer(self.colorAttribute, ARRAY_COUNT(NFDebugVertex_t, color), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFDebugVertex_t, color));

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindVertexArray(0);
}
*/

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {
    GLsizeiptr matrixSize = (GLsizeiptr)(16 * sizeof(float));
    GLintptr offset = (GLintptr)matrixSize;

    glBindBuffer(GL_UNIFORM_BUFFER, self.hUBO);

    // will allocate buffer's internal storage
    glBufferData(GL_UNIFORM_BUFFER, 2 * matrixSize, NULL, GL_STATIC_READ);

    // transfer view and projection matrix data to uniform buffer
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, matrixSize, viewMatrix.m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, matrixSize, projection.m);

    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    CHECK_GL_ERROR();
}

@end


@implementation NFRProgram

+ (id<NFRProgram>) createProgramObject:(NSString *)programName {

    if ([programName isEqualToString:@"DefaultModel"]) {
        NFRPhongProgram* programObj = [[[NFRPhongProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];

        NSLog(@"NFRProgram created and loaded DefaultModel shader");

        return programObj;
    }
    else if ([programName isEqualToString:@"Debug"]) {
        NFRDebugProgram* programObj = [[[NFRDebugProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];

        NSLog(@"NFRProgram created and loaded Debug shader");

        return programObj;
    }
    else {
        NSLog(@"WARNING: NFRUtils createProgramObject attempted to load an unknown program, returning nil");
    }
    
    return nil;
}

@end

