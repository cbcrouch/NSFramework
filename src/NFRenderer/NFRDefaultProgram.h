//
//  NFRDefaultProgram.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>


#import "NFRProgramProtocol.h"
#import "NFLightSource.h"

@interface NFRDefaultProgram : NSObject <NFRProgram>

typedef struct phongMaterialUniform_t {
    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;
    GLint shineLoc;

    GLint diffuseMapLoc;
    GLint specularMapLoc;
} phongMaterialUniform_t;

typedef struct directionalLightUniforms_t {
    GLint directionLoc;

    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;
} directionalLightUniforms_t;

typedef struct pointLightUniforms_t {
    GLint positionLoc;

    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;

    GLint constantLoc;
    GLint linearLoc;
    GLint quadraticLoc;
} pointLightUniforms_t;

typedef struct spotLightUniforms_t {
    GLint positionLoc;
    GLint directionLoc;

    GLint innerCutOffLoc;
    GLint outerCutOffLoc;

    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;

    GLint constantLoc;
    GLint linearLoc;
    GLint quadraticLoc;
} spotLightUniforms_t;

@property (nonatomic, assign) GLint vertexAttribute;
@property (nonatomic, assign) GLint normalAttribute;
@property (nonatomic, assign) GLint texCoordAttribute;

@property (nonatomic, assign) phongMaterialUniform_t materialUniforms;

@property (nonatomic, assign) directionalLightUniforms_t dirLightUniforms;
@property (nonatomic, assign) pointLightUniforms_t pointLightUniforms;
@property (nonatomic, assign) spotLightUniforms_t spotLightUniforms;

@property (nonatomic, assign) GLint modelMatrixLocation;
@property (nonatomic, assign) GLint viewPositionLocation;


//
// TODO: after getting basic directional light working move light space
//       matrix uniforms into the light uniform structs
//
@property (nonatomic, assign) GLint lightSpaceMatrixLoc;

//
// TODO: need to modify updateLightSpaceMatrix to take an object (wrapping a GLKMatrix4)
//
//- (void) updateLightSpaceMatrix:(GLKMatrix4)lightSpaceMatrix;
- (void) updateLightSpaceMatrix:(NSValue*)matValue;


@property (nonatomic, assign) GLuint hUBO;

@property (nonatomic, readwrite, assign) GLuint hProgram;

- (void) loadProgramInputPoints;

- (void) loadLight:(id<NFLightSource>)light;

@end
