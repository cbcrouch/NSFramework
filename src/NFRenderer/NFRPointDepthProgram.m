//
//  NFRPointDepthProgram.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFRPointDepthProgram.h"

//#import "NFCommonTypes.h"
#import "NFRUtils.h"

//#import "NFRResources.h"

@implementation NFRPointDepthProgram

- (void) loadProgramInputPoints {
    //
    // TODO: setup shader attributes and uniforms
    //
/*
    // shader attributes
    self.vertexAttribute = glGetAttribLocation(self.hProgram, "v_position");
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    // shader uniforms
    self.modelMatrixLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"model");
    NSAssert(self.modelMatrixLocation != -1, @"Failed to get model matrix uniform location");
*/
    CHECK_GL_ERROR();
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    //
    // TODO: bind VAO and enable vertex attribute
    //
/*
    glBindVertexArray(bufferAttributes.hVAO);
    glEnableVertexAttribArray(self.vertexAttribute);
    glBindVertexArray(0);
*/
    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    //
    // TODO: configure VAO and VBO for drawing
    //
/*
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
*/
    CHECK_GL_ERROR();
}

@end
