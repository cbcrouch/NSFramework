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

    phongMat.diffuseMapLoc = glGetUniformLocation(self.hProgram, "material.diffuseMap");
    NSAssert(phongMat.diffuseMapLoc != -1, @"failed to get uniform location");

    phongMat.specularMapLoc = glGetUniformLocation(self.hProgram, "material.specularMap");
    NSAssert(phongMat.diffuseMapLoc != -1, @"failed to get uniform location");

    [self setMaterialUniforms:phongMat];

    // light struct uniform locations
    pointLightUniforms_t phongLight;
    phongLight.ambientLoc = glGetUniformLocation(self.hProgram, "light.ambient");
    NSAssert(phongLight.ambientLoc != -1, @"failed to get uniform location");

    phongLight.diffuseLoc = glGetUniformLocation(self.hProgram, "light.diffuse");
    NSAssert(phongLight.diffuseLoc != -1, @"failed to get uniform location");

    phongLight.specularLoc = glGetUniformLocation(self.hProgram, "light.specular");
    NSAssert(phongLight.specularLoc != -1, @"failed to get uniform location");

    phongLight.positionLoc = glGetUniformLocation(self.hProgram, "light.position");
    NSAssert(phongLight.positionLoc != -1, @"failed to get uniform location");

    phongLight.constantLoc = glGetUniformLocation(self.hProgram, "light.constant");
    NSAssert(phongLight.constantLoc != -1, @"failed to get uniform location");

    phongLight.linearLoc = glGetUniformLocation(self.hProgram, "light.linear");
    NSAssert(phongLight.linearLoc != -1, @"failed to get uniform location");

    phongLight.quadraticLoc = glGetUniformLocation(self.hProgram, "light.quadratic");
    NSAssert(phongLight.quadraticLoc != -1, @"failed to get uniform location");

    [self setLightUniforms:phongLight];

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

    // NOTE: the vert attributes are bound to the VAO (and associated with the actively bound VBO)
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

- (void) loadLight:(id<NFLightSource>)light {
    glUseProgram(self.hProgram);

    glUniform3f(self.lightUniforms.ambientLoc, light.ambient.r, light.ambient.g, light.ambient.b);
    glUniform3f(self.lightUniforms.diffuseLoc, light.diffuse.r, light.diffuse.g, light.diffuse.b);
    glUniform3f(self.lightUniforms.specularLoc, light.specular.r, light.specular.g, light.specular.b);

    if ([light isKindOfClass:NFPointLight.class]) {
        NFPointLight* pointLight = light;
        glUniform3f(self.lightUniforms.positionLoc, pointLight.position.x, pointLight.position.y, pointLight.position.z);
        glUniform1f(self.lightUniforms.constantLoc, pointLight.constantAttenuation);
        glUniform1f(self.lightUniforms.linearLoc, pointLight.linearAttenuation);
        glUniform1f(self.lightUniforms.quadraticLoc, pointLight.quadraticAttenuation);
    }
    else if ([light isKindOfClass:NFSpotLight.class]) {
        //
        // TODO: implement
        //
        NSLog(@"WARNING: NFRDefaultProgram loadLight method not yet implemented for spot lights");
    }
    else if ([light isKindOfClass:NFDirectionalLight.class]) {
        //
        // TODO: implement
        //
        NSLog(@"WARNING: NFRDefaultProgram loadLight method not yet implemented for directional lights");
    }
    else {
        NSLog(@"WARNING: NFRDefaultProgram received unrecongized light type");
    }

    glUseProgram(0);
}

- (void) drawGeometry:(NFRGeometry*)geometry {
    glUseProgram(self.hProgram);

    //
    // TODO: need a better way of handling subroutines
    //
    [self activateSubroutine:@"PhongSubroutine"];

    //
    // TODO: the follow are also listed in the default mtl file and should be handled appropiately
    //
    // - Ni  (1.5)    // optical density
    // - Tr  (0  0)   // transparency
    // - Ke  (0 0 0)  // emissive

    glUniform3f(self.materialUniforms.ambientLoc, geometry.surfaceModel.Ka.r, geometry.surfaceModel.Ka.g, geometry.surfaceModel.Ka.b);
    glUniform3f(self.materialUniforms.diffuseLoc, geometry.surfaceModel.Kd.r, geometry.surfaceModel.Kd.g, geometry.surfaceModel.Kd.b);
    glUniform3f(self.materialUniforms.specularLoc,  geometry.surfaceModel.Ks.r, geometry.surfaceModel.Ks.g, geometry.surfaceModel.Ks.b);
    glUniform1f(self.materialUniforms.shineLoc, geometry.surfaceModel.Ns);

    for (NSString* key in geometry.textureDictionary) {
        if ([key isEqualToString:@"diffuseTexture"]) {
            NFRDataMapGL* textureGL = [geometry.textureDictionary objectForKey:key];
            [textureGL activateTexture:GL_TEXTURE0 withUniformLocation:self.materialUniforms.diffuseMapLoc];
        }
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
