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


//
// TODO: finish implementing (need ability to set cube map textures)
//

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
    glBindVertexArray(geometry.vertexBuffer.bufferAttributes.hVAO);

    //
    // TODO: draw without indices
    //
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, geometry.indexBuffer.bufferHandle);
    //glDrawElements(geometry.mode, (GLsizei)geometry.indexBuffer.numberOfElements, GL_UNSIGNED_SHORT, NULL);
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    glBindVertexArray(0);

    CHECK_GL_ERROR();
}

@end
