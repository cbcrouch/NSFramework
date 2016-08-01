//
//  NFRCubeMapProgram.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
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


    //
    // TODO: need to modify how vertex data is getting drawn
    //

    //glBufferData(GL_ARRAY_BUFFER, sizeof(skyboxVertices), &skyboxVertices, GL_STATIC_DRAW);

    //glEnableVertexAttribArray(self.vertexAttribute); // state should already be set in VAO

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
    }


    //geometry.vertexBuffer.bufferDataPointer
    //geometry.vertexBuffer.bufferDataSize


    glBindVertexArray(geometry.vertexBuffer.bufferAttributes.hVAO);

    // GL_INVALID_OPERATION on glBufferData

    //glBufferData(GL_ARRAY_BUFFER, geometry.vertexBuffer.bufferDataSize, geometry.vertexBuffer.bufferDataPointer, GL_STATIC_DRAW);
    //CHECK_GL_ERROR();


    glDrawArrays(GL_TRIANGLES, 0, 36);

    glBindVertexArray(0);

    for (id key in geometry.textureDictionary) {
        NFRDataMapGL* cubeMapGL = (geometry.textureDictionary)[key];
        [cubeMapGL deactivateTexture];
    }

    CHECK_GL_ERROR();
}

@end
