//
//  NFRDefaultProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRDefaultProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFRResources.h"

@implementation NFRDefaultProgram

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
@synthesize hProgram = _hProgram;

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


    //
    // TODO: need to allow for setting matrial properites based on the surface model
    //       (also need to support diffuse/specular/etc. texture maps
    //
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


    //
    // TODO: need to allow for setting dynamic lights using an NFLightSource object
    //
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

    CHECK_GL_ERROR();
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.texCoordAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));
    glVertexAttribPointer(self.normalAttribute, ARRAY_COUNT(NFVertex_t, norm), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, norm));
    glVertexAttribPointer(self.texCoordAttribute, ARRAY_COUNT(NFVertex_t, texCoord), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, texCoord));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) drawGeometry:(NFRGeometry*)geometry {
    glUseProgram(self.hProgram);

    //
    // TODO: need a better way of handling subroutines
    //
    [self activateSubroutine:geometry.subroutineName];

    for (id key in geometry.textureDictionary) {
        NFRDataMapGL* textureGL = [geometry.textureDictionary objectForKey:key];

        //
        // TODO: pass uniform location and texture unit num based on key string, also need to use the actual
        //       texture sampler uniforms in the default model shader
        //
        [textureGL activateTexture:GL_TEXTURE0 withUniformLocation:glGetUniformLocation(self.hProgram, (const GLchar *)"texSampler")];
    }

    glBindVertexArray(geometry.vertexBuffer.bufferAttributes.hVAO);

    [self updateModelMatrix:geometry.modelMatrix];

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, geometry.indexBuffer.bufferHandle);
    glDrawElements(geometry.mode, (GLsizei)geometry.indexBuffer.numberOfElements, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    glBindVertexArray(0);

    //
    // TODO: only if debug then deactivate all textures
    //
    for (id key in geometry.textureDictionary) {
        NFRDataMapGL* textureGL = [geometry.textureDictionary objectForKey:key];
        [textureGL deactivateTexture];
    }

    glUseProgram(0);
    CHECK_GL_ERROR();
}

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix {
    glProgramUniformMatrix4fv(self.hProgram, self.modelMatrixLocation, 1, GL_FALSE, modelMatrix.m);
    CHECK_GL_ERROR();
}

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {

    //
    // TODO: these utility methods do work but the introduce too much overhead, they will be kept
    //       around for the time being but the direct loading of UBO data should be preserved if possible
    //
    /*
     static const char* matrixType = @encode(GLKMatrix4);
     NSMutableArray* matrixArray = [[[NSMutableArray alloc] init] autorelease];
     [matrixArray addObject:[NSValue value:&viewMatrix withObjCType:matrixType]];
     [matrixArray addObject:[NSValue value:&projection withObjCType:matrixType]];
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

- (void)activateSubroutine:(NSString *)subroutine {
    if ([subroutine isEqualToString:@"PhongSubroutine"]) {
        GLuint phongSubroutine = self.phongSubroutine;
        glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(phongSubroutine));
    }
    else if ([subroutine isEqualToString:@"LightSubroutine"]) {
        GLuint lightSubroutine = self.lightSubroutine;
        glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(lightSubroutine));
    }
    else {
        NSLog(@"WARNING: NFRPhongProgram recieved unknown subroutine name in activeSubroutine method, no subroutine bound");
    }
}

- (void) updateViewPosition:(GLKVector3)viewPosition {
    glUseProgram(self.hProgram);
    glUniform3f(self.viewPositionLocation, viewPosition.x, viewPosition.y, viewPosition.z);
    glUseProgram(0);
    CHECK_GL_ERROR();
}

@end
