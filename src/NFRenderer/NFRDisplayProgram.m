//
//  NFRDisplayProgram.m
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import "NFRDisplayProgram.h"

#import "NFRUtils.h"

@implementation NFRDisplayProgram

- (void) loadProgramInputPoints {
    // shader uniforms
    self.textureUniform = glGetUniformLocation(self.hProgram, "screenTexture");
    NSAssert(self.textureUniform != -1, @"failed to get uniform location");

    //
    // TODO: load all uniforms and subroutines once added to the shader
    //

    // shader attributes
    self.vertexAttribute = glGetAttribLocation(self.hProgram, "v_position");
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    self.texCoordAttribute = glGetAttribLocation(self.hProgram, "v_texcoord");
    NSAssert(self.texCoordAttribute != -1, @"Failed to bind attribute");

    CHECK_GL_ERROR();
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.texCoordAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFScreenSpaceVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFScreenSpaceVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFScreenSpaceVertex_t, pos));
    glVertexAttribPointer(self.texCoordAttribute, ARRAY_COUNT(NFScreenSpaceVertex_t, texCoord), GL_FLOAT, GL_FALSE, sizeof(NFScreenSpaceVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFScreenSpaceVertex_t, texCoord));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

@end
