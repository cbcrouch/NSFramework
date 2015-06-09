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
    GLint matAmbientLoc;
    GLint matDiffuseLoc;
    GLint matSpecularLoc;
    GLint matShineLoc;
} phongMaterialUniform_t;

typedef struct phongLightUniform_t {
    GLint lightAmbientLoc;
    GLint lightDiffuseLoc;
    GLint lightSpecularLoc;
    GLint lightPositionLoc;
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

- (void) loadProgramInputPoints {

    //
    // TODO: get and set all the program input points
    //

    [self setModelMatrixLocation:glGetUniformLocation(self.hProgram, (const GLchar *)"model")];
    NSAssert(self.modelMatrixLocation != -1, @"failed to get model matrix uniform location");


#if 0
    // uniform buffer for view and projection matrix
    m_phongModel.hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:m_phongModel.hProgram];
    NSAssert(m_phongModel.hUBO != 0, @"failed to get uniform buffer handle");

    // material struct uniform locations
    m_phongModel.matLocs.matAmbientLoc = glGetUniformLocation(m_phongModel.hProgram, "material.ambient");
    NSAssert(m_phongModel.matLocs.matAmbientLoc != -1, @"failed to get uniform location");

    m_phongModel.matLocs.matDiffuseLoc = glGetUniformLocation(m_phongModel.hProgram, "material.diffuse");
    NSAssert(m_phongModel.matLocs.matDiffuseLoc != -1, @"failed to get uniform location");

    m_phongModel.matLocs.matSpecularLoc = glGetUniformLocation(m_phongModel.hProgram, "material.specular");
    NSAssert(m_phongModel.matLocs.matSpecularLoc != -1, @"failed to get uniform location");

    m_phongModel.matLocs.matShineLoc = glGetUniformLocation(m_phongModel.hProgram, "material.shininess");
    NSAssert(m_phongModel.matLocs.matShineLoc != -1, @"failed to get uniform location");

    // hardcoded material values (jade)
    glUseProgram(m_phongModel.hProgram);
    glUniform3f(m_phongModel.matLocs.matAmbientLoc, 0.135f, 0.2225f, 0.1575f);
    glUniform3f(m_phongModel.matLocs.matDiffuseLoc, 0.54f, 0.89f, 0.63f);
    glUniform3f(m_phongModel.matLocs.matSpecularLoc, 0.316228f, 0.316228f, 0.316228f);
    glUniform1f(m_phongModel.matLocs.matShineLoc, 128.0f * 0.1f);
    glUseProgram(0);

    // light struct uniform locations
    m_phongModel.lightLocs.lightAmbientLoc = glGetUniformLocation(m_phongModel.hProgram, "light.ambient");
    NSAssert(m_phongModel.lightLocs.lightAmbientLoc != -1, @"failed to get uniform location");

    m_phongModel.lightLocs.lightDiffuseLoc = glGetUniformLocation(m_phongModel.hProgram, "light.diffuse");
    NSAssert(m_phongModel.lightLocs.lightDiffuseLoc != -1, @"failed to get uniform location");

    m_phongModel.lightLocs.lightSpecularLoc = glGetUniformLocation(m_phongModel.hProgram, "light.specular");
    NSAssert(m_phongModel.lightLocs.lightSpecularLoc != -1, @"failed to get uniform location");

    m_phongModel.lightLocs.lightPositionLoc = glGetUniformLocation(m_phongModel.hProgram, "light.position");
    NSAssert(m_phongModel.lightLocs.lightPositionLoc != -1, @"failed to get uniform location");

    // hardcoded light values
    glUseProgram(m_phongModel.hProgram);
    glUniform3f(m_phongModel.lightLocs.lightAmbientLoc, 0.2f, 0.2f, 0.2f);
    glUniform3f(m_phongModel.lightLocs.lightDiffuseLoc, 0.5f, 0.5f, 0.5f);
    glUniform3f(m_phongModel.lightLocs.lightSpecularLoc, 1.0f, 1.0f, 1.0f);
    glUniform3f(m_phongModel.lightLocs.lightPositionLoc, 2.0f, 1.0f, 0.0f);
    glUseProgram(0);

    // view position uniform location
    m_phongModel.viewPositionLoc = glGetUniformLocation(m_phongModel.hProgram, "viewPos");
    NSAssert(m_phongModel.viewPositionLoc != -1, @"failed to get uniform location");

    // subroutine indices
    m_phongModel.lightSubroutine = glGetSubroutineIndex(m_phongModel.hProgram, GL_FRAGMENT_SHADER, "light_subroutine");
    NSAssert(m_phongModel.lightSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    m_phongModel.phongSubroutine = glGetSubroutineIndex(m_phongModel.hProgram, GL_FRAGMENT_SHADER, "phong_subroutine");
    NSAssert(m_phongModel.phongSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");
#endif
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

