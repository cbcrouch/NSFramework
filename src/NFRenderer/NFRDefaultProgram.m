//
//  NFRDefaultProgram.m
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFRDefaultProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFRResources.h"

/*
@interface NFRDefaultProgram()
{
    GLint m_shadowMapHandle;
}

@end
*/

@implementation NFRDefaultProgram

- (void) loadProgramInputPoints {
    // shader attributes
    self.vertexAttribute = glGetAttribLocation(self.hProgram, "v_position");
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    self.normalAttribute = glGetAttribLocation(self.hProgram, "v_normal");
    NSAssert(self.normalAttribute != -1, @"Failed to bind attribute");

    self.texCoordAttribute = glGetAttribLocation(self.hProgram, "v_texcoord");
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

    self.materialUniforms = phongMat;

    // load point light uniforms
    pointLightUniforms_t pointLight;

    pointLight.ambientLoc = glGetUniformLocation(self.hProgram, "pointlight.ambient");
    NSAssert(pointLight.ambientLoc != -1, @"failed to get uniform location");

    pointLight.diffuseLoc = glGetUniformLocation(self.hProgram, "pointlight.diffuse");
    NSAssert(pointLight.diffuseLoc != -1, @"failed to get uniform location");

    pointLight.specularLoc = glGetUniformLocation(self.hProgram, "pointlight.specular");
    NSAssert(pointLight.specularLoc != -1, @"failed to get uniform location");

    pointLight.positionLoc = glGetUniformLocation(self.hProgram, "pointlight.position");
    NSAssert(pointLight.positionLoc != -1, @"failed to get uniform location");

    pointLight.constantLoc = glGetUniformLocation(self.hProgram, "pointlight.constant");
    NSAssert(pointLight.constantLoc != -1, @"failed to get uniform location");

    pointLight.linearLoc = glGetUniformLocation(self.hProgram, "pointlight.linear");
    NSAssert(pointLight.linearLoc != -1, @"failed to get uniform location");

    pointLight.quadraticLoc = glGetUniformLocation(self.hProgram, "pointlight.quadratic");
    NSAssert(pointLight.quadraticLoc != -1, @"failed to get uniform location");

    self.pointLightUniforms = pointLight;

    // load directional light uniforms
    directionalLightUniforms_t dirLight;

    dirLight.directionLoc = glGetUniformLocation(self.hProgram, "directionalLight.direction");
    NSAssert(dirLight.directionLoc != -1, @"failed to get uniform location");

    dirLight.ambientLoc = glGetUniformLocation(self.hProgram, "directionalLight.ambient");
    NSAssert(dirLight.ambientLoc != -1, @"failed to get uniform location");

    dirLight.diffuseLoc = glGetUniformLocation(self.hProgram, "directionalLight.diffuse");
    NSAssert(dirLight.diffuseLoc != -1, @"failed to get uniform location");

    dirLight.specularLoc = glGetUniformLocation(self.hProgram, "directionalLight.specular");
    NSAssert(dirLight.specularLoc != -1, @"failed to get uniform location");

    self.dirLightUniforms = dirLight;

    // load spot light uniforms
    spotLightUniforms_t spotLight;

    spotLight.positionLoc = glGetUniformLocation(self.hProgram, "spotLight.position");
    NSAssert(spotLight.positionLoc != -1, @"failed to get uniform location");

    spotLight.directionLoc = glGetUniformLocation(self.hProgram, "spotLight.direction");
    NSAssert(spotLight.directionLoc != -1, @"failed to get uniform location");

    spotLight.innerCutOffLoc = glGetUniformLocation(self.hProgram, "spotLight.innerCutOff");
    NSAssert(spotLight.innerCutOffLoc != -1, @"failed to get uniform location");

    spotLight.outerCutOffLoc = glGetUniformLocation(self.hProgram, "spotLight.outerCutOff");
    NSAssert(spotLight.outerCutOffLoc != -1, @"failed to get uniform location");

    spotLight.ambientLoc = glGetUniformLocation(self.hProgram, "spotLight.ambient");
    NSAssert(spotLight.ambientLoc != -1, @"failed to get uniform location");

    spotLight.diffuseLoc = glGetUniformLocation(self.hProgram, "spotLight.diffuse");
    NSAssert(spotLight.diffuseLoc != -1, @"failed to get uniform location");

    spotLight.specularLoc = glGetUniformLocation(self.hProgram, "spotLight.specular");
    NSAssert(spotLight.specularLoc != -1, @"failed to get uniform location");

    spotLight.constantLoc = glGetUniformLocation(self.hProgram, "spotLight.constant");
    NSAssert(spotLight.constantLoc != -1, @"failed to get uniform location");

    spotLight.linearLoc = glGetUniformLocation(self.hProgram, "spotLight.linear");
    NSAssert(spotLight.linearLoc != -1, @"failed to get uniform location");

    spotLight.quadraticLoc = glGetUniformLocation(self.hProgram, "spotLight.quadratic");
    NSAssert(spotLight.quadraticLoc != -1, @"failed to get uniform location");

    self.spotLightUniforms = spotLight;

    // model matrix uniform location
    self.modelMatrixLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"model");
    NSAssert(self.modelMatrixLocation != -1, @"failed to get model matrix uniform location");


    //
    // TODO: remove these uniform locations once the directional light is working correctly,
    //       each light struct should have a light space matrix and shadow map uniform
    //
    self.lightSpaceMatrixUniform = glGetUniformLocation(self.hProgram, (const GLchar *)"lightSpace");
    NSAssert(self.lightSpaceMatrixUniform != -1, @"failed to get light space matrix uniform location");

    self.shadowMapUniform = glGetUniformLocation(self.hProgram, (const GLchar *)"shadowMap");
    NSAssert(self.shadowMapUniform != -1, @"failed to get shadow map uniform location");


    // view position uniform location
    self.viewPositionLocation = glGetUniformLocation(self.hProgram, "viewPos");
    NSAssert(self.viewPositionLocation != -1, @"failed to get uniform location");

    // uniform buffer for view and projection matrix
    self.hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:self.hProgram];
    NSAssert(self.hUBO != 0, @"failed to get uniform buffer handle");

    CHECK_GL_ERROR();
}


//
// TODO: need to modify updateLightSpaceMatrix to take an object (wrapping a GLKMatrix4)
//

//
// TODO: make sure this method gets removed after the light space matrix gets moved into
//       each light object (should then be able to update them on the loadLight call)
//
- (void) updateLightSpaceMatrix:(NSValue*)matValue {
    GLKMatrix4 lightSpaceMatrix;
    [matValue getValue:&lightSpaceMatrix];

    glProgramUniformMatrix4fv(self.hProgram, self.lightSpaceMatrixUniform, 1, GL_FALSE, lightSpaceMatrix.m);
    CHECK_GL_ERROR();
}

- (void) setShadowMap:(NSValue*)valueObj {
    GLint textureId;
    [valueObj getValue:&textureId];

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureId);

    glUseProgram(self.hProgram);
    glUniform1i(self.shadowMapUniform, GL_TEXTURE1 - GL_TEXTURE0);
    glUseProgram(0);

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

    //
    // TODO: should not update uniforms every frame if the values have not changed
    //
    if ([light isKindOfClass:NFPointLight.class]) {
        NFPointLight* pointLight = light;
        glUniform3f(self.pointLightUniforms.positionLoc, pointLight.position.x, pointLight.position.y, pointLight.position.z);

        glUniform3f(self.pointLightUniforms.ambientLoc, pointLight.ambient.r, pointLight.ambient.g, pointLight.ambient.b);
        glUniform3f(self.pointLightUniforms.diffuseLoc, pointLight.diffuse.r, pointLight.diffuse.g, pointLight.diffuse.b);
        glUniform3f(self.pointLightUniforms.specularLoc, pointLight.specular.r, pointLight.specular.g, pointLight.specular.b);

        glUniform1f(self.pointLightUniforms.constantLoc, pointLight.constantAttenuation);
        glUniform1f(self.pointLightUniforms.linearLoc, pointLight.linearAttenuation);
        glUniform1f(self.pointLightUniforms.quadraticLoc, pointLight.quadraticAttenuation);
    }
    else if ([light isKindOfClass:NFSpotLight.class]) {
        NFSpotLight* spotLight = light;

        glUniform3f(self.spotLightUniforms.positionLoc, spotLight.position.x, spotLight.position.y, spotLight.position.z);
        glUniform3f(self.spotLightUniforms.directionLoc, spotLight.direction.x, spotLight.direction.y, spotLight.direction.z);

        glUniform1f(self.spotLightUniforms.innerCutOffLoc, spotLight.innerCutOff);
        glUniform1f(self.spotLightUniforms.outerCutOffLoc, spotLight.outerCutOff);

        glUniform3f(self.spotLightUniforms.ambientLoc, spotLight.ambient.r, spotLight.ambient.g, spotLight.ambient.b);
        glUniform3f(self.spotLightUniforms.diffuseLoc, spotLight.diffuse.r, spotLight.diffuse.g, spotLight.diffuse.b);
        glUniform3f(self.spotLightUniforms.specularLoc, spotLight.specular.r, spotLight.specular.g, spotLight.specular.b);

        glUniform1f(self.spotLightUniforms.constantLoc, spotLight.constantAttenuation);
        glUniform1f(self.spotLightUniforms.linearLoc, spotLight.linearAttenuation);
        glUniform1f(self.spotLightUniforms.quadraticLoc, spotLight.quadraticAttenuation);
    }
    else if ([light isKindOfClass:NFDirectionalLight.class]) {
        NFDirectionalLight* dirLight = light;
        glUniform3f(self.dirLightUniforms.directionLoc, dirLight.direction.x, dirLight.direction.y, dirLight.direction.z);

        glUniform3f(self.dirLightUniforms.ambientLoc, dirLight.ambient.r, dirLight.ambient.g, dirLight.ambient.b);
        glUniform3f(self.dirLightUniforms.diffuseLoc, dirLight.diffuse.r, dirLight.diffuse.g, dirLight.diffuse.b);
        glUniform3f(self.dirLightUniforms.specularLoc, dirLight.specular.r, dirLight.specular.g, dirLight.specular.b);
    }
    else {
        NSLog(@"WARNING: NFRDefaultProgram received unrecongized light type");
    }

    CHECK_GL_ERROR();
    glUseProgram(0);
}

- (void) drawGeometry:(NFRGeometry*)geometry {

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
            NFRDataMapGL* textureGL = (geometry.textureDictionary)[key];
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
        NFRDataMapGL* textureGL = (geometry.textureDictionary)[key];
        [textureGL deactivateTexture];
    }

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

- (void) updateViewPosition:(GLKVector3)viewPosition {
    glUseProgram(self.hProgram);
    glUniform3f(self.viewPositionLocation, viewPosition.x, viewPosition.y, viewPosition.z);
    glUseProgram(0);
    CHECK_GL_ERROR();
}

@end
