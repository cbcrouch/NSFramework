//
//  NFRCubeMapProgram.m
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import "NFRCubeMapProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFRResources.h"


@implementation NFRCubeMapProgram

- (void) loadProgramInputPoints {

    // shader uniforms
    self.textureUniform = glGetUniformLocation(self.hProgram, "cubeMap");
    NSAssert(self.textureUniform != -1, @"failed to get uniform location");

    // shader attributes
    self.vertexAttribute = glGetAttribLocation(self.hProgram, "v_position");
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    // uniform buffer for view and projection matrix
    self.hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:self.hProgram];
    NSAssert(self.hUBO != 0, @"failed to get uniform buffer handle");
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glEnableVertexAttribArray(self.vertexAttribute);
    glBindVertexArray(0);

    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    CHECK_GL_ERROR();
}

- (void) drawGeometry:(NFRGeometry*)geometry {
    for (NSString* key in geometry.textureDictionary) {
        if ([key isEqualToString:@"cubeMap"]) {
            NFRCubeMapGL* cubeMapGL = (geometry.textureDictionary)[key];
            [cubeMapGL activateTexture:GL_TEXTURE0 withUniformLocation:self.textureUniform];
        }
        else if ([key isEqualToString:@"cubeMapHandle"]) {
            NSValue* valueObj = (geometry.textureDictionary)[key];

            GLuint textureID = 0;
            [valueObj getValue:&textureID];

            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_CUBE_MAP, textureID);
            glUniform1i(self.textureUniform, GL_TEXTURE0 - GL_TEXTURE0);
            CHECK_GL_ERROR();
        }
    }

    glBindVertexArray(geometry.vertexBuffer.bufferAttributes.hVAO);

    //
    // TODO: shouldn't be updating the geometry every draw
    //
    glBindBuffer(GL_ARRAY_BUFFER, geometry.vertexBuffer.bufferHandle);
    glBufferData(GL_ARRAY_BUFFER, geometry.vertexBuffer.bufferDataSize, geometry.vertexBuffer.bufferDataPointer, GL_STATIC_DRAW);
    CHECK_GL_ERROR();

    glDrawArrays(GL_TRIANGLES, 0, 36);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    //
    // TODO: texture deactivation will cause a crash if a texture handle has been set in the texture
    //       dictionary instead of an object, need to decided whether or not to fully support setting
    //       texture handles directory, just texture objects, or both
    //
    for (id key in geometry.textureDictionary) {
        NFRDataMapGL* cubeMapGL = (geometry.textureDictionary)[key];
        [cubeMapGL deactivateTexture];
    }

    CHECK_GL_ERROR();
}

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {
    GLsizeiptr matrixSize = (GLsizeiptr)(16 * sizeof(float));
    GLintptr offset = (GLintptr)matrixSize;

    // remove the translation component
    viewMatrix.m03 = 0.0f;
    viewMatrix.m13 = 0.0f;
    viewMatrix.m23 = 0.0f;

    viewMatrix.m33 = 1.0f;

    viewMatrix.m30 = 0.0f;
    viewMatrix.m31 = 0.0f;
    viewMatrix.m32 = 0.0f;

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
