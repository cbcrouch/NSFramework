//
//  NFRProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRProgram.h"
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

- (void) setStateWithVAO:(GLint)hVAO withVBO:(GLint)hVBO {
    //
    // TODO: implement
    //
}

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {
    //
    // TODO: implement
    //
}

@end


@interface NFRDebugProgram : NSObject <NFRProgram>
//
// TODO: make these properties
//
//    GLint vertAttrib;
//    GLint normAttrib;
//    GLint colorAttrib;

/*
 typedef struct debugProgram_t {
 // vertex shader inputs
 GLint modelLoc;
 GLuint hUBO;

 // fragment shader inputs

 // program handle
 GLuint hProgram;
 } debugProgram_t;
 */

@property (nonatomic, readwrite, assign) GLuint hProgram;

@end

@implementation NFRDebugProgram

@synthesize hProgram = _hProgram;

- (void) setStateWithVAO:(GLint)hVAO withVBO:(GLint)hVBO {
    //
    // TODO: implement
    //
}

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {
    //
    // TODO: implement
    //
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

        NSLog(@"NFRProgram created and loaded Debug shader");

        //
        // TODO: get vertex attribute handles and perform UBO setup
        //

        /*
         // setup uniform for model matrix
         m_debugProgram.modelLoc = glGetUniformLocation(m_debugProgram.hProgram, (const GLchar *)"model");
         NSAssert(m_debugProgram.modelLoc != -1, @"Failed to get MVP uniform location");

         // uniform buffer for view and projection matrix
         m_debugProgram.hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:m_debugProgram.hProgram];
         NSAssert(m_debugProgram.hUBO != 0, @"failed to get uniform buffer handle");
         */
        
        return programObj;
    }
    else {
        NSLog(@"WARNING: NFRUtils createProgramObject attempted to load an unknown program, returning nil");
    }
    
    return nil;
}

@end

